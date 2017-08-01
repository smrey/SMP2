# CRUK.sh script
## Introduction
This script takes fastq files in the location specified by the first command line argument, runs the SMP2 app in the 
basespace environment and downloads the required output files for further analysis and interpretation.


A CentOS or Ubuntu operating system is required with the Illumina BaseSpace Command Line Interface installed and 
configured to access the correct BaseSpace location and username. For further instructions see 
https://help.basespace.illumina.com/articles/descriptive/basespace-cli/.


### Required input files
  * The Illumina SampleSheet.csv with the desired project identifier for BaseSpace in the Experiment Name field.

  * Fastq pairs (read 1 and read 2) for each of the samples.

  * An optional text file called "not_bs_samples.txt" containing the names of any samples on the Illumina SampleSheet.csv for which
analysis in BaseSpace with the SMP2 app is not required. This should be placed in the same location as the script.

  * An optional text file containing tumour normal pairs in the format <tumour_sample_id> <tab> <blood_sample_id> with each 
pair on a new line. This is required if the arrangement of samples in the Illumina SampleSheet.csv does not match the expected
order, which is tumour sample then normal sample for each patient in order. An example of this order is: S1 tumour sample for person 
1, S2 blood sample for person 1, S3 tumour sample for person 2, S4 blood sample for person 2, etc. This file must be located in the same 
directory as the script and the name of the file and extension supplied as the fourth command line argument e.g. pairs.txt.


## Files which will be downloaded
The script will download the generated Excel spreadsheet for downstream analysis. It will also download all of the BAM files and 
the BAM index files. These files will be downloaded to the directory passed as the second command line argument. 


## Instructions for use
### Prerequisites
The Illumina CLI must be correctly set up to point to the required BaseSpace location. A config file can be specified in the script.

The SMP2 app must have been imported. Instructions to import apps are available on the Illumina website.

### Changes to the script required for initial set up
  * Set up the correct BaseSpace location and set the $CONFIG variable to the name of the config file.

  * Ensure that the $APPNAME variable is set to the correct name for the app.


### Instructions for running the script
  * Place the SampleSheet.csv and the fastqs generated for each of the samples into a directory. The full path to this directory must be passed
as the first command line argument.

  * Create the desired output directory for the results and pass this as the second command line argument.

  * Pass the sample name of the negative control sample as the third command line argument.

  * If a manually created file containing the tumour blood pairs is required, place this file in the same directory as the script. Pass the
name of this file as the fourth command line argument.

  * If there are samples which were run, and so are on the sample sheet, that are not required to be analysed using the SMP2 BaseSpace application, 
the names of these samples should be placed in a file called "not_bs_samples.txt" with each name on a new line. The file "not_bs_samples.txt"
should be placed in the same directory as the script.

#### Full example
bash CRUK.sh /path/to/samplesheet/and/fastqs/ /path/to/save/results/ NEGATIVECONTROL pairs.txt

Note that the fourth argument is optional.

## Creating the tumour blood pairs file
If the sample sheet is not set up with the pattern tumour sample followed by paired blood sample for each patient sequentially, it is necessary
to manually specify the tumour-normal pairs.
Create a text file according to the following pattern with the sample names:

tumour1 tab blood1 newline


tumour2 tab blood2 newline


tumour3 tab blood3 newline


...and so on for each pair of samples belonging to each individual.

The text file can have any name. It must be placed in the same directory as the script and the name of the file passed as the fourth command
line argument.
