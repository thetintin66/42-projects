#!/bin/bash

# ==============================================================
# update_all_submodules.sh
#
# Met à jour en cascade TOUS les submodules (même imbriqués) de
# TOUS les dépôts git trouvés dans le dossier courant (ex: rank00,
# rank01, rank02, rank03...), puis pousse tous les changements.
#
# Pour chaque submodule (en partant des plus profonds) :
#   1. S'il a des changements non commités -> add + commit + push
#   2. Si le push est rejeté -> pull --no-rebase puis retente le push
#      (continue même si ça échoue encore, avec un avertissement)
#   3. Une fois les submodules traités, met à jour les pointeurs
#      dans le dépôt parent -> add + commit + push
#
# Usage : lance-le depuis le dossier racine (celui qui contient
# rank00, rank01, rank02, rank03, etc.) :
#
#   chmod +x update_all_submodules.sh
#   ./update_all_submodules.sh
# ==============================================================

set -u

ROOT_DIR="$(pwd)"
ERRORS=()

log()      { echo -e "\033[1;34m[INFO]\033[0m $1"; }
success()  { echo -e "\033[1;32m[OK]\033[0m $1"; }
warn()     { echo -e "\033[1;33m[ATTENTION]\033[0m $1"; }

# Commit + push le dépôt courant s'il y a des changements.
# Si le push est rejeté, tente un pull --no-rebase puis repush.
commit_and_push() {
    local repo_path="$1"
    local commit_msg="$2"

    if [[ -n "$(git status --porcelain)" ]]; then
        log "Changements détectés dans : $repo_path"
        git add -A
        git commit -m "$commit_msg" >/dev/null

        if git push 2>/tmp/push_err.log; then
            success "Push réussi : $repo_path"
        else
            warn "Push rejeté pour $repo_path, tentative de pull --no-rebase..."
            if git pull --no-rebase >/tmp/pull_err.log 2>&1; then
                if git push 2>>/tmp/push_err.log; then
                    success "Push réussi après pull : $repo_path"
                else
                    warn "Échec du push même après pull pour : $repo_path (voir /tmp/push_err.log)"
                    ERRORS+=("$repo_path (push impossible après pull)")
                fi
            else
                warn "Le pull a échoué (probablement un conflit) pour : $repo_path (voir /tmp/pull_err.log)"
                ERRORS+=("$repo_path (conflit lors du pull)")
            fi
        fi
    else
        log "Rien à commit dans : $repo_path"
    fi
}

# Traite récursivement un dépôt : d'abord ses submodules (les plus
# profonds en premier), puis lui-même.
process_repo() {
    local repo_path="$1"
    cd "$repo_path" || return

    if [[ -f ".gitmodules" ]]; then
        # Récupère la liste des chemins de submodules déclarés
        local submodule_paths
        submodule_paths=$(git config --file .gitmodules --get-regexp path | awk '{print $2}')

        for sub in $submodule_paths; do
            if [[ -d "$sub/.git" || -f "$sub/.git" ]]; then
                process_repo "$repo_path/$sub"
                cd "$repo_path" || return
            fi
        done
    fi

    commit_and_push "$repo_path" "Mise à jour automatique"
    cd "$ROOT_DIR" || return
}

if [[ ! -d "$ROOT_DIR/.git" ]]; then
    warn "Aucun dépôt git trouvé dans $ROOT_DIR (pas de dossier .git ici)."
    warn "Lance ce script depuis la racine de ton dépôt (ex: 42-projects)."
    exit 1
fi

log "Dépôt principal détecté : $ROOT_DIR"
echo ""
echo "=============================================="
process_repo "$ROOT_DIR"
echo "=============================================="

echo "=============================================="
if [[ ${#ERRORS[@]} -eq 0 ]]; then
    success "Tout est à jour et poussé avec succès !"
else
    warn "Terminé, mais avec des erreurs sur :"
    for e in "${ERRORS[@]}"; do
        echo "  - $e"
    done
    warn "Va régler ces dépôts manuellement (conflits probables)."
fi