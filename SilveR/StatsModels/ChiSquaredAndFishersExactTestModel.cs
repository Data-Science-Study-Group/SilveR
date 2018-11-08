﻿using SilveR.Helpers;
using SilveR.Models;
using SilveR.Validators;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Linq;
using System.Text;

namespace SilveR.StatsModels
{
    public class ChiSquaredAndFishersExactTestModel : AnalysisModelBase
    {
        [Required]
        [CheckUsedOnceOnly]
        [DisplayName("Response")]
        public string Response { get; set; }

        [Required]
        [CheckUsedOnceOnly]
        [DisplayName("Grouping factor")]
        public string GroupingFactor { get; set; }

        [Required]
        [CheckUsedOnceOnly]
        [DisplayName("Response categories")]
        public string ResponseCategories { get; set; }


        [DisplayName("Chi-squared test")]
        public bool ChiSquaredTest { get; set; } = true;

        [DisplayName("Fisher's exact test")]
        public bool FishersExactTest { get; set; } = true;

        [DisplayName("Hypothesis")]
        public string Hypothesis { get; set; } = "0.05";

        public IEnumerable<string> HypothesesList
        {
            get { return new List<string>() { "Two-sided", "Less-than", "Greater-than" }; }
        }

        [DisplayName("Barnard's test")]
        public bool BarnardsTest { get; set; }

        [DisplayName("Significance level")]
        public string Significance { get; set; } = "0.05";

        public IEnumerable<string> SignificancesList
        {
            get { return new List<string>() { "0.1", "0.05", "0.01", "0.001" }; }
        }


        public ChiSquaredAndFishersExactTestModel() : this(null) { }

        public ChiSquaredAndFishersExactTestModel(IDataset dataset)
            :base(dataset, "ChiSquaredAndFishersExactTest") {   }


        public override ValidationInfo Validate()
        {
            ChiSquaredAndFishersExactTestValidator chiSquaredAndFishersExactTestValidator = new ChiSquaredAndFishersExactTestValidator(this);
            return chiSquaredAndFishersExactTestValidator.Validate();
        }

        public override string[] ExportData()
        {
            DataTable dtNew =DataTable.CopyForExport();

            //Get the response, treatment and covariate columns by removing all other columns from the new datatable
            foreach (string col in dtNew.GetVariableNames())
            {
                if (Response != col && GroupingFactor != col && ResponseCategories != col)
                {
                    dtNew.Columns.Remove(col);
                }
            }

            //ensure that all data is trimmed
            dtNew.TrimAllDataInDataTable();

            //if the response is blank then remove that row
            dtNew.RemoveBlankRow(Response);

            return dtNew.GetCSVArray();
        }

        public override IEnumerable<Argument> GetArguments()
        {
            List<Argument> args = new List<Argument>();

            args.Add(ArgumentHelper.ArgumentFactory(nameof(Response), Response));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(GroupingFactor), GroupingFactor));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(ResponseCategories), ResponseCategories));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(ChiSquaredTest), ChiSquaredTest));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(FishersExactTest), FishersExactTest));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Hypothesis), Hypothesis));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(BarnardsTest), BarnardsTest));
            args.Add(ArgumentHelper.ArgumentFactory(nameof(Significance), Significance));

            return args;
        }

        public override void LoadArguments(IEnumerable<Argument> arguments)
        {
            ArgumentHelper argHelper = new ArgumentHelper(arguments);

            this.Response = argHelper.ArgumentLoader(nameof(Response), Response);
            this.GroupingFactor = argHelper.ArgumentLoader(nameof(GroupingFactor), GroupingFactor);
            this.ResponseCategories = argHelper.ArgumentLoader(nameof(ResponseCategories), ResponseCategories);
            this.ChiSquaredTest = argHelper.ArgumentLoader(nameof(ChiSquaredTest), ChiSquaredTest);
            this.FishersExactTest = argHelper.ArgumentLoader(nameof(FishersExactTest), FishersExactTest);
            this.Hypothesis = argHelper.ArgumentLoader(nameof(Hypothesis), Hypothesis);
            this.BarnardsTest = argHelper.ArgumentLoader(nameof(BarnardsTest), BarnardsTest);
            this.Significance = argHelper.ArgumentLoader(nameof(Significance), Significance);
        }

        public override string GetCommandLineArguments()
        {
            ArgumentFormatter argFormatter = new ArgumentFormatter();
            StringBuilder arguments = new StringBuilder();

            arguments.Append(" " + argFormatter.GetFormattedArgument(Response, true)); //4
            arguments.Append(" " + argFormatter.GetFormattedArgument(GroupingFactor, true)); //5
            arguments.Append(" " + argFormatter.GetFormattedArgument(ResponseCategories, true)); //6          

            arguments.Append(" " + argFormatter.GetFormattedArgument(ChiSquaredTest)); //7
            arguments.Append(" " + argFormatter.GetFormattedArgument(FishersExactTest)); //8
            arguments.Append(" " + argFormatter.GetFormattedArgument(Hypothesis)); //9
            arguments.Append(" " + argFormatter.GetFormattedArgument(BarnardsTest)); //10
            arguments.Append(" " + argFormatter.GetFormattedArgument(Significance)); //11

            return arguments.ToString();
        }
    }
}