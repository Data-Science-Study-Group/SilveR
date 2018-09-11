﻿using SilveRModel.StatsModel;
using System;
using System.Collections.Generic;
using System.Data;

namespace SilveRModel.Validators
{
    public class LinearRegressionAnalysisValidator : ValidatorBase
    {
        private readonly LinearRegressionAnalysisModel lrVariables;

        public LinearRegressionAnalysisValidator(LinearRegressionAnalysisModel lr)
            : base(lr.DataTable)
        {
            lrVariables = lr;
        }

        public override ValidationInfo Validate()
        {
            //go through all the column names, if any are numeric then stop the analysis
            List<string> allVars = new List<string>();
            allVars.AddRange(lrVariables.Treatments);

            if (lrVariables.ContinuousFactors != null)
                allVars.AddRange(lrVariables.ContinuousFactors);

            if (lrVariables.OtherDesignFactors != null)
                allVars.AddRange(lrVariables.OtherDesignFactors);

            allVars.Add(lrVariables.Response);
            allVars.Add(lrVariables.Covariate);
            if (!CheckColumnNames(allVars)) return ValidationInfo;

            if (!CheckTreatmentsHaveLevels(lrVariables.Treatments, true)) return ValidationInfo;

            //Do checks to ensure that treatments contain a response etc and the responses contain a treatment etc...
            if (!CheckResponsesPerLevel(lrVariables.Treatments, lrVariables.Response)) return ValidationInfo;
            
            if (lrVariables.ContinuousFactors != null)
                if (!CheckResponsesPerLevel(lrVariables.ContinuousFactors, lrVariables.Response, "continuous")) return ValidationInfo;

            if (lrVariables.OtherDesignFactors != null)
                if (!CheckResponsesPerLevel(lrVariables.OtherDesignFactors, lrVariables.Response, "other treatment")) return ValidationInfo;

            //First create a list of catogorical variables selected (i.e. as treatments and other factors)
            List<string> categorical = new List<string>();
            categorical.AddRange(lrVariables.Treatments);

            if (lrVariables.ContinuousFactors != null)
                categorical.AddRange(lrVariables.ContinuousFactors);

            if (lrVariables.OtherDesignFactors != null)
                categorical.AddRange(lrVariables.OtherDesignFactors);

            //do data checks on the treatments/other factors and response
            if (!FactorAndResponseCovariateChecks(categorical, lrVariables.Response)) return ValidationInfo;

            //do data checks on the treatments/other factors and covariate (if selected)
            if (!String.IsNullOrEmpty(lrVariables.Covariate))
            {
                if (!FactorAndResponseCovariateChecks(categorical, lrVariables.Covariate)) return ValidationInfo;
            }

            if (!String.IsNullOrEmpty(lrVariables.Covariate) && String.IsNullOrEmpty(lrVariables.PrimaryFactor))
            {
                ValidationInfo.AddErrorMessage("You have selected a covariate but no primary factor is selected.");
            }

            //if get here then no errors so return true
            return ValidationInfo;
        }

        private bool FactorAndResponseCovariateChecks(List<string> categorical, string continuous)
        {
            foreach (string catFactor in categorical) //go through each categorical factor and do the check on each
            {
                string factorType;
                if (lrVariables.Treatments.Contains(catFactor))
                {
                    factorType = "treatment";
                }
                else
                {
                    factorType = "other factor";
                }

                string responseType;
                if (lrVariables.Response.Contains(continuous))
                {
                    responseType = "response";
                }
                else
                {
                    responseType = "covariate";
                }

                //Now that the whole column checks have been done, ensure that the treatment and response for each row is ok
                List<string> categoricalRow = new List<string>();
                List<string> continuousRow = new List<string>();

                foreach (DataRow row in DataTable.Rows) //assemble a list of the categorical data and the continuous data...
                {
                    categoricalRow.Add(row[catFactor].ToString());
                    continuousRow.Add(row[continuous].ToString());
                }

                for (int i = 0; i < DataTable.Rows.Count; i++) //use for loop cos its easier to compare the indexes of the cat and cont rows
                {
                    //Check that the "response" does not contain non-numeric data
                    double parsedValue;
                    bool parsedOK = Double.TryParse(continuousRow[i], out parsedValue);
                    if (!String.IsNullOrEmpty(continuousRow[i]) && !parsedOK)
                    {
                        ValidationInfo.AddErrorMessage("The " + responseType + " (" + lrVariables.Response + ") selected contain non-numerical data which cannot be processed. Please check the raw data and make sure the data was entered correctly.");
                        return false;
                    }

                    //Check that there are no responses where the treatments are blank
                    if (String.IsNullOrEmpty(categoricalRow[i]) && !String.IsNullOrEmpty(continuousRow[i]))
                    {
                        ValidationInfo.AddErrorMessage("The " + factorType + " (" + catFactor + ") selected contains missing data where there are observations present in the " + responseType + " variable. Please check the raw data and make sure the data was entered correctly.");

                        return false;
                    }

                    //check that the "response" contains data for each "treatment" (not fatal)
                    if (!String.IsNullOrEmpty(categoricalRow[i]) && String.IsNullOrEmpty(continuousRow[i]))
                    {
                        string mess = "The " + responseType + " selected contains missing data.";
                        if (responseType == "covariate")
                        {
                            mess = mess + Environment.NewLine + " Any response that does not have a corresponding covariate will be excluded from the analysis.";
                        }

                        ValidationInfo.AddWarningMessage(mess);
                    }
                }

                //check transformations
                foreach (DataRow row in DataTable.Rows)
                {
                    CheckTransformations(row, lrVariables.ResponseTransformation, lrVariables.Response, "response");

                    CheckTransformations(row, lrVariables.CovariateTransformation, lrVariables.Covariate, "covariate");
                }
            }

            //if got here then all checks ok, return true
            return true;
        }
    }
}