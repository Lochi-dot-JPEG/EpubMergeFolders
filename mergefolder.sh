#!/usr/bin/bash

# Path to put merged files
OUTPUT_PATH=~/merged

# Get absolute directory of this script
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

# Get absolute path to merging script
MERGE_SCRIPT_PATH="${SCRIPT_DIR}/epubmerge/epubmerge.py"

# Prompt to pick folders
VOLUMES=$(zenity --separator="%" --no-markup --directory --file-selection --multiple --text="Choose what folders to merge. Each selected folder will seperately merge.")

# Temporarily convert any spaces in path to -
VOLUMES_NO_SPACES=`echo $VOLUMES | tr ' ' '-'`

# Convert the seperator from zenity to spaces
VOLUMES_SPACED=`echo $VOLUMES_NO_SPACES | tr '%' ' '`

echo "Output directory, to put merged epubs:"
read -e -i $OUTPUT_PATH inputted_directory

if [ ! -d $inputted_directory ]
then
  echo "$inputted_directory doesn't exist."
  echo "Using default directory"
elif [ "$inputted_directory" = "" ]
then
  echo "Using default directory"
else
  OUTPUT_PATH=$inputted_directory
fi

echo "What should the series be called?"
echo "FORMAT \"(your input now) (folder name).epub\""
read SERIESNAME

# Remove spaces from series name
SERIESNAME=`echo $SERIESNAME | tr ' ' '-'`

echo "Remember not to include % or - in your file paths :)"

# Make output folders
mkdir -p ${OUTPUT_PATH}/${SERIESNAME}

# Convert to array (I don't know if this is necessary)
items=($VOLUMES_SPACED)

# Loop through each folder
for item in ${items[@]}
do
	echo "Merging ${item}"

	# Revert dashes to spaces
	path=`echo $item | tr '-' ' '`
	cd "$path"

	# Find .epub files to merge
	files=`ls *.epub`

	# Get folder name
	foldername=$(basename -- "$path")

	# Remove spaces from folder name
	foldername=`echo $foldername | tr ' ' '-'`


	output_dir="${OUTPUT_PATH}/${SERIESNAME}/${SERIESNAME}-${foldername}.epub"

	# Merge files
	python $MERGE_SCRIPT_PATH -o $output_dir $files

	#echo "Merging ${item} complete"
done

echo "All selected folders merged!"
echo "Output has been saved in ${OUTPUT_PATH}/${SERIESNAME}/"
