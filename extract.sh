#!/bin/bash
#SBATCH --time=8:0:0
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=10G
#SBATCH --job-name=biobank_extract
#SBATCH --error=./outcomes_%A.err
#SBATCH --output=./outcomes_%A.out
#FILENAME: extract biobank
#AUTHOR : Amy Mason
#PURPOSE: extracts fields for UKBB pipeline
#INPUT: None, edit this file direct
#OUTPUT: outcomes_field.dta containing majority of fields for UKBB pipeline (needs 33 added by hand from old stata file)
# move to working folder that contains ukbconv and all_fields.txt - list of wanted fields
#
#
cd /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/BBmirror/
# copy UKBB data
mkdir temp
cp -a -n "/rds/project/asb38/rds-asb38-ceu-ukbiobank/phenotype/P7439/pre_qc_data/Data/data_20210825_48061/additional/." "./temp/"
# run ukbconv
ukbconv temp/ukb48061.enc_ukb stata -iall_fields.txt -ooutcomes_fields2
# cleanup UKBB files 
#rm -r  "./temp/"
