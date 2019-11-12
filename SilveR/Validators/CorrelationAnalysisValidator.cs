using SilveR.StatsModels;
using System.Collections.Generic;

namespace SilveR.Validators
{
    public class CorrelationAnalysisValidator : ValidatorBase
    {
        private readonly CorrelationAnalysisModel caVariables;

        public CorrelationAnalysisValidator(CorrelationAnalysisModel ca)
            : base(ca.DataTable)
        {
            caVariables = ca;
        }

        public override ValidationInfo Validate()
        {
            //first just check to ensure that the user has actually selected something to output!
            if (!caVariables.Estimate && !caVariables.TestStatistic && !caVariables.PValue && !caVariables.Scatterplot && !caVariables.Matrixplot && !caVariables.ByCategoriesAndOverall)
            {
                ValidationInfo.AddErrorMessage("You have not selected anything to output!");
                return ValidationInfo;
            }

            //Create a list of all variables
            List<string> allVars = new List<string>();
            allVars.AddVariables(caVariables.Responses);
            allVars.AddVariables(caVariables.FirstCatFactor);
            allVars.AddVariables(caVariables.SecondCatFactor);
            allVars.AddVariables(caVariables.ThirdCatFactor);
            allVars.AddVariables(caVariables.FourthCatFactor);

            if (!CheckColumnNames(allVars))
                return ValidationInfo;

            if ((caVariables.FirstCatFactor != null && CountDistinctLevels(caVariables.FirstCatFactor) < 2)
               || (caVariables.SecondCatFactor != null && CountDistinctLevels(caVariables.SecondCatFactor) < 2)
               || (caVariables.ThirdCatFactor != null && CountDistinctLevels(caVariables.ThirdCatFactor) < 2)
               || (caVariables.FourthCatFactor != null && CountDistinctLevels(caVariables.FourthCatFactor) < 2))
            {
                ValidationInfo.AddErrorMessage("At least one of your categorisation factors only has one level. Please remove it from the analysis.");
                return ValidationInfo;
            }

            //Create a list of categorical variables selected (i.e. the cat factors)
            List<string> categorical = new List<string>();
            categorical.AddVariables(caVariables.FirstCatFactor);
            categorical.AddVariables(caVariables.SecondCatFactor);
            categorical.AddVariables(caVariables.ThirdCatFactor);
            categorical.AddVariables(caVariables.FourthCatFactor);

            foreach (string response in caVariables.Responses)
            {
                if (!CheckIsNumeric(response))
                {
                    ValidationInfo.AddErrorMessage("The Response (" + response + ") contains non-numeric data that cannot be processed. Please check the data and make sure it was entered correctly.");
                    return ValidationInfo;
                }
            }

            CheckTransformations(caVariables.Transformation, caVariables.Responses);

            if (!CheckResponsesPerLevel(categorical, caVariables.Responses, "categorical"))
                return ValidationInfo;

            //check response and cat factors contain values
            if (!CheckFactorsAndResponsesNotBlank(categorical, caVariables.Responses, "categorisation factor"))
                return ValidationInfo;

            //if get here then no errors so return true
            return ValidationInfo;
        }
    }
}