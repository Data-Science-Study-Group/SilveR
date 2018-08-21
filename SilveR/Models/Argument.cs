﻿using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SilveRModel.Models
{
    public partial class Argument
    {
        public int ArgumentID { get; set; }


        public int AnalysisID { get; set; }

        [Required]
        [StringLength(50)]
        public string Name { get; set; }

        [StringLength(100)]
        public string Value { get; set; }

        public Analysis Analysis { get; set; }
    }
}