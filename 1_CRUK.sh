#!/bin/bash
set -euo pipefail

#Description: CRUK Basespace app pipeline
#Author: Sara Rey
#Status: DEVELOPMENT/TESTING
Version=1.0

# Aliases for local python VE
#alias python='/home/transfer/basespace_vm/venv/bin/python' ####
#PATH="$PATH":/home/transfer/basespace_vm/venv/bin/ ####

# How to use
# bash 1_CRUK.sh <path_to_sample_sheet> <name_of_negative_control_sample> <sample_pairs_text_file (optional)>

# Variables
CONFIG="pmg-euc1"
APPID="91091"
NOTBASESPACE="not_bs.txt"


# Usage checking
if [ "$#" -lt 2 ]
	then
		echo "Commandline args incorrect. Usage: $0 <path_to_sample_sheet> <name_of_negative_control_sample> <sample_pairs_text_file (optional)>." 
		exit -1
fi

# Variables dependent on command line arguments
INPUTFOLDER="$1"
NEGATIVE="$2"
FASTQFOLDER="$INPUTFOLDER""/Data/*/"

# Check if file containing sample pairs has been supplied or if one should be automatically generated
if [ "$#" -lt 3 ]
	then
		SAMPLEPAIRS="$INPUTFOLDER""SamplePairs.txt"
		makePairs=1
	else
		SAMPLEPAIRS="$3"
		# Skip generation of a SamplePairs.txt file
		makePairs=-1
fi


# Check for the presence of the file with samples not to upload to BaseSpace in the same directory as the script
if [[ -e $NOTBASESPACE ]]
	then
		samples_to_skip=1
		# Check that the provided file is not empty
		if ! [[ -s $NOTBASESPACE ]]
			then
				echo "The file "$NOTBASESPACE" is empty. When this file exists, it must contain the names of samples that are in the SampleSheet.csv, but should not be uploaded to BaseSpace."
				exit -1
		fi
	else
		samples_to_skip=-1
		# Notify the user that all samples in the sample sheet will be uploaded
		echo "No "$NOTBASESPACE" file found in the same directory as the script. All samples on the SampleSheet.csv will be uploaded to BaseSpace."
fi


# Declare an array to store the sample ids in order
declare -a samplesArr
# Initial entry created to avoid downstream error when appending to array
samplesArr+=1 


# Parse SampleSheet
function parseSampleSheet {

	echo "Parsing sample sheet"
	
	# Obtain project name from sample sheet
	projectName=$(grep "Experiment Name" "$INPUTFOLDER""SampleSheet.csv" | cut -d, -f2 | tr -d " ")

	# Obtain list of samples from sample sheet
	for line in $(sed "1,/Sample_ID/d" "$INPUTFOLDER""SampleSheet.csv" | tr -d " ")
		do 
			# Obtain sample name and patient name		
			samplename=$(printf "$line" | cut -d, -f1 | sed 's/[^a-zA-Z0-9]+/-/g')

	 		# Skip any empty sample ids- both empty and whitespace characters (but not tabs at present)
	 		if [[ "${#samplename}" = 0 ]] || [[ "$samplename" =~ [" "] ]]
				then
					continue
	 		fi

			# Append information to list array- to retain order for sample pairing
			samplesArr=("${samplesArr[@]}" "$samplename")
	done
}


function pairSamples {

	echo "Pairing samples"

	# Create/clear file which holds the sample name and the patient identifiers
	> "$SAMPLEPAIRS"
	
	# Iterate through the samples and exclude any samples that are not for basespace
	# Pair the samples assuming the order tumour then normal and create a file of these pairs
	# Create array containing the samples that are not tumour-normal pairs
	# Check if there are any samples on the run that are not for BaseSpace and so should not be paired
	if [[ -e $NOTBASESPACE ]]
		then
			mapfile -t notPairs < $NOTBASESPACE
			notPairs=("${notPairs[@]}" "$NEGATIVE") 
		else
			notPairs+=("$NEGATIVE")
	fi	
	
	# Exclude non tumour-normal pairs from pair file creation		
	grep -f <(printf -- '%s\n' "${notPairs[@]}") -v <(printf '%s\n' "${samplesArr[@]:1}") | awk -F '\t' 'NR % 2 {printf "%s\t", $1;} !(NR % 2) {printf "%s\n", $1;}' >"$SAMPLEPAIRS"

}


function locateFastqs {

	echo "Uploading fastqs"

	if [[ "$samples_to_skip" == 1 ]]
		then
			fastqlist=$( printf -- '%s\n' "${samplesArr[@]:1}" | grep -f "$NOTBASESPACE" -v )
		else
			fastqlist=$(printf -- '%s\n' "${samplesArr[@]:1}")
	fi
	
	for fastq in $(printf -- '%s\n' "$fastqlist")
		do
			f1=$FASTQFOLDER${fastq}*_R1_*.fastq.gz
			f2=$FASTQFOLDER${fastq}*_R2_*.fastq.gz
		
			# Obtain basespace identifier for each sample
			baseSpaceId=$(bs -c "$CONFIG" upload sample -p $projectName -i "$fastq" $f1 $f2 --terse)
	done

}


function launchApp {

	# Launch app for each pair of samples in turn as tumour normal pairs then download analysis files
	
	# Obtain basespace ID of negative control- this is not an optional input through the commandline app launch
	negId=$(bs -c "$CONFIG" list samples --project "$projectName" --sample "$NEGATIVE" --terse)

	# Obtain the project identifier
	projectId=$(bs -c "$CONFIG" list projects --project-name "$projectName" --terse)

	while read pair
		do
			# Stop iteration on first empty line of SamplePairs.txt file in case EOF marker is absent for any reason
			if [[ -z $pair ]]
				then
					exit
			fi
			echo "Launching app for ""$pair"
			
			tum=$(printf "$pair" | cut -d$'\t' -f1)
			nor=$(printf "$pair" | cut -d$'\t' -f2)

			# Obtain sample ids from basespace
			tumId=$(bs -c "$CONFIG" list samples --project "$projectName" --sample "$tum" --terse)
			norId=$(bs -c "$CONFIG" list samples --project "$projectName" --sample "$nor" --terse)

			# Launch app and store the appsession ID	
			appSessionId=$(bs -c "$CONFIG" launch app -i "$APPID" "$negId" "$norId" "$projectName" "$tumId" --terse)
	done <"$SAMPLEPAIRS"

}



# Call the functions

#Check sample sheet exists at location provided
if ! [[ -e "$INPUTFOLDER""SampleSheet.csv" ]]
	then
		echo "Sample Sheet not found at input folder location"
		exit -1
fi


# Parse sample sheet to obtain required information
parseSampleSheet


# Pair samples according to order in sample sheet if manually created pairs file has not been supplied
if [[ "$makePairs" == 1 ]]
	then
		pairSamples
fi


# Read out the sample pairs in the order tumour blood with each pair on a new line 
echo "Displaying sample pairs:" 
cat "$SAMPLEPAIRS"
printf $'\n'
echo "Abort the script if the samples are paired incorrectly and create a file of the pairs (see README.MD for details about this file)." 
printf $'\n'


# Create project in basespace
echo "Creating project"
#bs -c "$CONFIG" create project "$projectName" ####


# Get fastqs and upload to basespace
#locateFastqs ####


# Kick off the app for each pair in turn and download files
#launchApp ####

# Delete the file that contained the samples that were not for upload and analysis in BaseSpace
rm "$NOTBASESPACE"

# Queue next script in the pipeline for half an hours time- test syntax
at now +30 minutes -f ./<name_of_script>
