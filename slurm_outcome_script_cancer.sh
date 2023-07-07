#!/bin/bash
#SBATCH --time=8:0:0
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --error=outcomes.err
#SBATCH --mem=10G
#SBATCH --job-name=qctool
#SBATCH --error=/rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/outcomes_%A.err
#SBATCH --output=/rds/project/jmmh2/rds-jmmh2-projects/zz_mr/AMY_bb_outcomes/outcomes_%A.out
#FILENAME: stata_outcomes
#AUTHOR : Amy Mason
#PURPOSE: run outcomes file
#INPUT: All managed from the Master.do file
#OUTPUT: outcomes as requested from spreadsheet in .csv and .dta form

module load ceuadmin/stata/14
cd /rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/Steps
#stata -b do Master.do
stata < "/rds/project/asb38/rds-asb38-ceu-ukbiobank/projects/P7439/zz_mr/Amy/AMY_bb_outcomes/Code/Stata_outcomes/Steps/Settings_Cancer.do"


date
