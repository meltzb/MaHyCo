#!/bin/bash
#
# This script changes the reference of testcases writted on a list : list_of_cases_to_change
# Lancement :
# cd mahyco
# un fichier list_of_cases_to_change a été créé par ctest au préalable
# ./src/bascule_ref.sh .
#

# -----------------------------------------------------
# Aide
# -----------------------------------------------------
function helpme {
  echo "Procédure de lancement de la mise à jour des cas de non régression"
  echo "Depuis la racine, lancer :"
  echo "./NONREGRESSION/bascule_ref.sh ."
  echo ""
  echo "Ce script suppose que la compilation est faite dans le répertoire build/"
  echo "et que la non régression a tourné avec ctest pour produire le fichier list_of_cases_to_change"

  echo "Pilotage par variable d'environnement :"
  echo "AFFICHE_DIFF : affiche le diff lorsqu'il y a des écarts"
  echo "OUVRE_PARAVIEW : ouvre paraview pour visualiser les écarts"
  echo "PLOT_TIME_HISTORY_DIFF : trace les sorties bilan de time history (exécution et référence)"
  echo "BASCULE_FORCEE : accepte les changements de résultats sans poser la question, incompatible avec AFFICHE_DIFF et OUVRE_PARAVIEW"
}

# -----------------------------------------------------
# Lancement de la procédure
# $1 : chemin vers la racine mahyco
#
# Pilotage par variable d'environnement :
# AFFICHE_DIFF : affiche le diff lorsqu'il y a des écarts
# OUVRE_PARAVIEW : ouvre paraview pour visualiser les écarts
# BASCULE_FORCEE : accepte les changements de résultats sans poser la question
# -----------------------------------------------------
function main {
  
  local readonly mahyco_root_dir=$1
  local readonly test_dir=$mahyco_root_dir/NONREGRESSION

  if [ $mahyco_root_dir == "-h" ] ; then 
    helpme
    return 0
  fi

  # Vérification que le répertoire test_dir existe bien
  # ie que le script est lancé depuis la racine de Mahyco
  if [ ! -d $test_dir ] ; then
    echo "Impossible de trouver le chemin vers le répertoire $test_dir"
    helpme
    return -1
  fi

  # Utile uniquement s'il y a des cas tests à mettre à jour identifiés par ctest
  if [ ! -e list_of_cases_to_change ]; then
    echo "Le fichier list_of_cases_to_change n'existe pas."
    echo "Lancer ctest dans le répertoire build pour créer ce fichier."
    return 0
  fi

  echo "============================================================="
  echo "LANCEMENT DE LA PROCEDURE DE MISE A JOUR DES RESULTATS"
  echo "============================================================="
  echo "- Chemin vers le répertoire des cas de non reg : $test_dir"
  for cas in $(cat list_of_cases_to_change); do
    local readonly cas_dir=${test_dir}/$cas
    if [[ -d ${cas_dir} ]]; then
      echo ""
      echo "- Lancement du cas : $cas"
      echo "----> Répertoire du cas test = $test_dir/$cas"
      cp $cas_dir/Donnees.arc .

      # Lecture du découpage en sous-domaines
      test1=$(grep nsd Donnees.arc | grep 4)
      echo $test1 > test
      echo "----> Découpage avec 4 sous-domaines dans une direction ? $test1"
      test2=$(grep "2" test)
      echo "----> Découpage avec 4x2 sous-domaines ? $test2"
      test3=$(grep "2 2 2" Donnees.arc)
      echo "----> Découpage avec 2x2x2 sous-domaines ? $test3"
      test4=$(grep "2 2" test)
      echo "----> Découpage avec 2x2 sous-domaines ? $test4"

      # Exécution du cas test en choisissant le bon nombre de sous-domaines

      if [ "$test1" != "" ] ; then  
        # cas parallèle avec 4 sd dans une direction
	    if [ "$test2" != "" ] ; then  
          # Découpage 4x2 = 8 sd
          echo "----> Exécution du cas sur 8 procs..."
          mpiexec -n 8 $mahyco_root_dir/build/src/Mahyco Donnees.arc > /dev/null
          RUN_PROC="cas sur 8 procs"
	    else
          # Découpage 4x1 = 4 sd
          echo "----> Exécution du cas sur 4 procs..."
          mpiexec -n 4 $mahyco_root_dir/build/src/Mahyco Donnees.arc > /dev/null
          RUN_PROC="cas sur 4 procs"
	    fi
      else
        # Découpage nsd "sans 4"
        if [ "$test3" != "" ] ; then
          # Découpage 2x2x2
          echo "----> Exécution du cas sur 8 procs..."
          mpiexec -n 8 $mahyco_root_dir/build/src/Mahyco Donnees.arc > /dev/null
          RUN_PROC="cas sur 8 procs"
	    else 
        if [ "$test4" != "" ] ; then  
          # Découpage 2x2
          echo "----> Exécution du cas sur 4 procs..."
          mpiexec -n 4 $mahyco_root_dir/build/src/Mahyco Donnees.arc > /dev/null
          RUN_PROC="cas sur 4 procs"
        else  
          # nsd = rien => cas séquentiel
          echo "----> Exécution du cas séquentiel..."
          $mahyco_root_dir/build/src/Mahyco Donnees.arc > /dev/null
          RUN_PROC="cas sur 1 proc"
        fi
      fi  # test_3
	fi  # test_1

	# Lancement en protection - reprise
	#  $mahyco_root_dir/build/src/Mahyco -arcane_opt max_iteration 10 Donnees.arc
	#  reprise
	#  $mahyco_root_dir/build/src/Mahyco -arcane_opt continue Donnees.arc
	# avec mpiexec -n 4 ou 8

  # Visualisation des résultats :
  if [ $OUVRE_PARAVIEW ]; then
    echo "----> Lancement de paraview pour le cas "
    rm _execution _reference # si jamais ils existent déjà, on supprime les liens symboliques
    ln -s $cas_dir/output/depouillement _reference
    ln -s output/depouillement _execution
    paraview _execution/ensight.case &
    paraview _reference/ensight.case
    rm _execution _reference
  fi

  if [ $PLOT_TIME_HISTORY_DIFF ] ; then
    echo "----> Tracé du time_history output [cette exécution] et $cas_dir/output [référence]"
    module load python3
    for f in $(ls $cas_dir/output/courbes/gnuplot); do
      python3 $mahyco_root_dir/utils/plot_time_history.py output/courbes/gnuplot/$f --reference $cas_dir/output/courbes/gnuplot/$f  &
    done
  fi

  if [ $AFFICHE_DIFF ]; then 
    echo "----> Affichage du diff output [cette exécution] et $cas_dir/output [référence]"
    diff -r output $cas_dir/output
  fi
        
	echo "----> Changement des résultats sur le cas $cas, exécution $RUN_PROC"
  if [ $BASCULE_FORCEE ]; then
    reponse="Yes"  # pour mettre à jour les références de façon systématique
  else
	  echo "----> Basculer Yes/No ?"
	  read reponse  
  fi

	if  [[ "$reponse" == "Yes" ]]; then
	    rm -rf $cas_dir/output
      # Sauvegarde des résultats
	    mv output $cas_dir/output
      # Suppression des éléments inutiles
	    rm -rf $cas_dir/output/listing*
	    rm -rf $cas_dir/output/checkpoint_info.xml
	    rm -rf $cas_dir/output/protection
	    rm -rf $cas_dir/output/courbes
	  fi
  fi
  done
}

main $@

