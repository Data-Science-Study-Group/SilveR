﻿using SilveR.Helpers;
using SilveR.Models;
using SilveR.Validators;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;

namespace SilveR.StatsModels
{
    public class CorrelationAnalysisModel : AnalysisModelBase
    {
        [HasAtLeastTwoEntries]
        [CheckUsedOnceOnly]
        [DisplayName("Responses")]
        public IEnumerable<string> Responses { get; set; }

        public IEnumerable<string> TransformationsList
        {
            get { return new List<string>() { "None", "Log10", "Loge", "Square Root", "ArcSine" }; }
        }

        [DisplayName("Response transformation")]
        public string Transformation { get; set; }

        [CheckUsedOnceOnly]
        [DisplayName("1st factor")]
        public string FirstCatFactor { get; set; }

        [CheckUsedOnceOnly]
        [DisplayName("2nd factor")]
        public string SecondCatFactor { get; set; }

        [CheckUsedOnceOnly]
        [DisplayName("3rd factor")]
        public string ThirdCatFactor { get; set; }

        [CheckUsedOnceOnly]
        [DisplayName("4th factor")]
        public string FourthCatFactor { get; set; }

        public IEnumerable<string> MethodsList
        {
            get { return new List<string>() { "Pearson", "Kendall", "Spearman" }; }
        }

        [DisplayName("Method")]
        public string Method { get; set; }

        public IEnumerable<string> HypothesesList
        {
            get { return new List<string>() { "2-sided", "Less than", "Greater than" }; }
        }

        [DisplayName("Hypothesis")]
        public string Hypothesis { get; set; }

        [DisplayName("Estimate")]
        public bool Estimate { get; set; } = true;

        [DisplayName("Statistic")]
        public bool Statistic { get; set; } = true;

        [DisplayName("p-value")]
        public bool PValue { get; set; } = true;

        [DisplayName("Scatterplot")]
        public bool Scatterplot { get; set; }

        [DisplayName("Matrixplot")]
        public bool Matrixplot { get; set; }

        [DisplayName("Significance level")]
        public string Significance { get; set; } = "0.05";

        public IEnumerable<string> SignificancesList
        {
            get { return new List<string>() { "0.1", "0.05", "0.01", "0.001" }; }
        }

        [DisplayName("By categories and overall")]
        public bool ByCategoriesAndOverall { get; set; }

        public CorrelationAnalysisModel() : this(null) { }

        public CorrelationAnalysisModel(IDataset dataset)
            :base(dataset, "CorrelationAnalysis") { }


        public override ValidationInfo Validate()
        {
            CorrelationAnalysisValidator correlationAnalysisValidator = new CorrelationAnalysisValidator(this);
            return correlationAnalysisValidator.Validate();
        }

        public override string[] ExportData()
        {
            DataTable dtNew = DataTable.CopyForExport();

            //Get the response, treatment and covariate columns by removing all other columns from the new datatable
            foreach (string columnName in dtNew.GetVariableNames())
            {
                if (!Responses.Contains(columnName) && FirstCatFactor != columnName && SecondCatFactor != columnName && ThirdCatFactor != columnName && FourthCatFactor != columnName)
                {
                    dtNew.Columns.Remove(columnName);
                }
            }

            //ensure that all data is trimmed
            dtNew.TrimAllDataInDataTable();

            //Generate a "catfact" column from the CatFactors!
            DataColumn catFactor = new DataColumn("catfact");
            dtNew.Columns.Add(catFactor);

            foreach (DataRow r in dtNew.Rows) //go through each row...
            {
                string firstCatFactorValue = null;
                string secondCatFactorValue = null;
                string thirdCatFactorValue = null;
                string fourthCatFactorValue = null;

                if (!String.IsNullOrEmpty(FirstCatFactor))
                    firstCatFactorValue = r[FirstCatFactor].ToString() + " ";

                if (!String.IsNullOrEmpty(SecondCatFactor))
                    secondCatFactorValue = r[SecondCatFactor].ToString() + " ";

                if (!String.IsNullOrEmpty(ThirdCatFactor))
                    thirdCatFactorValue = r[ThirdCatFactor].ToString() + " ";

                if (!String.IsNullOrEmpty(FourthCatFactor))
                    fourthCatFactorValue = r[FourthCatFactor].ToString();

                string catFactorValue = firstCatFactorValue + secondCatFactorValue + thirdCatFactorValue + fourthCatFactorValue;
                r["catfact"] = catFactorValue.Trim(); //copy the cat factor to the new column
            }

            //Now do transformations
            foreach (string resp in Responses)
            {
                dtNew.TransformColumn(resp, Transformation);
            }

            return dtNew.GetCSVArray();
        }

        public override IEnumerable<Argument> GetArguments()
        {
            List<Argument> args = new List<Argument>();

            args.Add(ArgumentHelper.ArgumentFactory(nameof(Responses), Responses));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Transformation), Transformation));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(FirstCatFactor), FirstCatFactor));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(SecondCatFactor), SecondCatFactor));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(ThirdCatFactor), ThirdCatFactor));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(FourthCatFactor), FourthCatFactor));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Method), Method));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Hypothesis), Hypothesis));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Estimate), Estimate));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Statistic), Statistic));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(PValue), PValue));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Scatterplot), Scatterplot));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Matrixplot), Matrixplot));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Significance), Significance));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(ByCategoriesAndOverall), ByCategoriesAndOverall));

            return args;
        }

        public override  void LoadArguments(IEnumerable<Argument> arguments)
        {
            ArgumentHelper argHelper = new ArgumentHelper(arguments);

            this.Responses = argHelper.ArgumentLoader(nameof(Responses), Responses);
            this.FirstCatFactor = argHelper.ArgumentLoader(nameof(FirstCatFactor), FirstCatFactor);
            this.SecondCatFactor = argHelper.ArgumentLoader(nameof(SecondCatFactor), SecondCatFactor);
            this.ThirdCatFactor = argHelper.ArgumentLoader(nameof(ThirdCatFactor), ThirdCatFactor);
            this.FourthCatFactor = argHelper.ArgumentLoader(nameof(FourthCatFactor), FourthCatFactor);
            this.Transformation = argHelper.ArgumentLoader(nameof(Transformation), Transformation);
            this.Method = argHelper.ArgumentLoader(nameof(Method), Method);
            this.Hypothesis = argHelper.ArgumentLoader(nameof(Hypothesis), Hypothesis);
            this.Estimate = argHelper.ArgumentLoader(nameof(Estimate), Estimate);
            this.Statistic = argHelper.ArgumentLoader(nameof(Statistic), Statistic);
            this.PValue = argHelper.ArgumentLoader(nameof(PValue), PValue);
            this.Scatterplot = argHelper.ArgumentLoader(nameof(Scatterplot), Scatterplot);
            this.Matrixplot = argHelper.ArgumentLoader(nameof(Matrixplot), Matrixplot);
            this.Significance = argHelper.ArgumentLoader(nameof(Significance), Significance);
            this.ByCategoriesAndOverall = argHelper.ArgumentLoader(nameof(ByCategoriesAndOverall), ByCategoriesAndOverall);
        }

        public override string GetCommandLineArguments()
        {
            ArgumentFormatter argFormatter = new ArgumentFormatter();
            StringBuilder arguments = new StringBuilder();

            //get responses, comma separated
            arguments.Append(" " + argFormatter.GetFormattedArgument(Responses)); //4

            //get transforms
            arguments.Append(" " + argFormatter.GetFormattedArgument(Transformation)); //5

            //1st cat factor
            arguments.Append(" " + argFormatter.GetFormattedArgument(FirstCatFactor, true)); //6

            //2nd cat factor
            arguments.Append(" " + argFormatter.GetFormattedArgument(SecondCatFactor, true)); //7

            //3rd cat factor
            arguments.Append(" " + argFormatter.GetFormattedArgument(ThirdCatFactor, true)); //8

            //4th cat factor
            arguments.Append(" " + argFormatter.GetFormattedArgument(FourthCatFactor, true)); //9

            //Method
            arguments.Append(" " + argFormatter.GetFormattedArgument(Method)); //10

            //Hypothesis
            arguments.Append(" " + argFormatter.GetFormattedArgument(Hypothesis)); //11

            //Mean
            arguments.Append(" " + argFormatter.GetFormattedArgument(Estimate)); //12

            //N
            arguments.Append(" " + argFormatter.GetFormattedArgument(Statistic)); //13

            //St Dev
            arguments.Append(" " + argFormatter.GetFormattedArgument(PValue)); //14

            //Variances
            arguments.Append(" " + argFormatter.GetFormattedArgument(Scatterplot)); //15

            //St Err
            arguments.Append(" " + argFormatter.GetFormattedArgument(Matrixplot)); //16

            //Min and Max
            arguments.Append(" " + argFormatter.GetFormattedArgument(Significance)); //17

            //By Categories and Overall
            arguments.Append(" " + argFormatter.GetFormattedArgument(ByCategoriesAndOverall)); //18

            return arguments.ToString();
        }
    }
}