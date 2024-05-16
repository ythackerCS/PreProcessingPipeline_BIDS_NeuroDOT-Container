#!/bin/bash


die(){
    echo >&2 "$@"
    exit 1
}

echo $@

SUBJECT_MAT=$1
shift
PARAMS=$1
shift
SCAN_ID=$1
shift
SESSION_ID=$1
shift
SESSION_LABEL=$1
shift
PROJECT=$1

dt=`date --utc +%Y%m%d-%H%M%S`

echo $dt 

USER=$(curl -u $XNAT_USER:$XNAT_PASS https://oxi.circ.wustl.edu/xapi/workflows/$XNAT_WORKFLOW_ID | jq .createUser)

echo "user is, $USER"

OUTPUTFOLDER_NOTEBOOK="/outputfiles/preprocessing_notebook"
OUTPUTFOLDER_IMAGES="/outputfiles/images/"

mkdir $OUTPUTFOLDER_NOTEBOOK $OUTPUTFOLDER_IMAGES

echo 'papermill neuro_dot/NeuroDOT_PreProcessing_Notebook.ipynb $OUTPUTFOLDER_NOTEBOOK/output.ipynb -p patient_data /input/$SUBJECT_MAT -p params_file /input/$PARAMS -p saveImagePath $OUTPUTFOLDER_IMAGES'

papermill neuro_dot/NeuroDOT_PreProcessing_Notebook.ipynb $OUTPUTFOLDER_NOTEBOOK/output.ipynb -p participant_data /input/$SUBJECT_MAT -p params_file /input/$PARAMS -p saveImagePath $OUTPUTFOLDER_IMAGES

python neuro_dot/makeXML.py $SCAN_ID $SESSION_ID $SESSION_LABEL $PROJECT $USER

python -m nbconvert --to html $OUTPUTFOLDER_NOTEBOOK/output.ipynb --output $OUTPUTFOLDER_NOTEBOOK/output.html

python neuro_dot/html2Img.py $OUTPUTFOLDER_NOTEBOOK/output.html $OUTPUTFOLDER_IMAGES/output.jpg