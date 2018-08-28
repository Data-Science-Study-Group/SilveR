﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using SilveRModel.Models;

namespace SilveR.Migrations
{
    [DbContext(typeof(SilveRContext))]
    partial class SilveRContextModelSnapshot : ModelSnapshot
    {
        protected override void BuildModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "2.1.2-rtm-30932");

            modelBuilder.Entity("SilveRModel.Models.Analysis", b =>
                {
                    b.Property<int>("AnalysisID")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("AnalysisGuid")
                        .IsRequired()
                        .HasMaxLength(128);

                    b.Property<int?>("DatasetID");

                    b.Property<string>("DatasetName")
                        .HasMaxLength(50);

                    b.Property<DateTime>("DateAnalysed")
                        .HasColumnType("datetime");

                    b.Property<string>("HtmlOutput");

                    b.Property<string>("RProcessOutput");

                    b.Property<int>("ScriptID");

                    b.Property<string>("Tag")
                        .HasMaxLength(200)
                        .IsUnicode(false);

                    b.HasKey("AnalysisID");

                    b.HasIndex("DatasetID");

                    b.HasIndex("ScriptID");

                    b.ToTable("Analyses");
                });

            modelBuilder.Entity("SilveRModel.Models.Argument", b =>
                {
                    b.Property<int>("ArgumentID")
                        .ValueGeneratedOnAdd();

                    b.Property<int>("AnalysisID");

                    b.Property<string>("Name")
                        .IsRequired()
                        .HasMaxLength(50);

                    b.Property<string>("Value")
                        .HasMaxLength(100);

                    b.HasKey("ArgumentID");

                    b.HasIndex("AnalysisID");

                    b.ToTable("Arguments");
                });

            modelBuilder.Entity("SilveRModel.Models.Dataset", b =>
                {
                    b.Property<int>("DatasetID")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("DatasetName")
                        .IsRequired()
                        .HasMaxLength(50)
                        .IsUnicode(false);

                    b.Property<DateTime>("DateUpdated");

                    b.Property<string>("TheData")
                        .IsRequired()
                        .IsUnicode(false);

                    b.Property<int>("VersionNo");

                    b.HasKey("DatasetID");

                    b.ToTable("Datasets");
                });

            modelBuilder.Entity("SilveRModel.Models.Script", b =>
                {
                    b.Property<int>("ScriptID")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("ScriptDisplayName")
                        .IsRequired()
                        .HasMaxLength(50)
                        .IsUnicode(false);

                    b.Property<string>("ScriptFileName")
                        .IsRequired()
                        .HasMaxLength(50)
                        .IsUnicode(false);

                    b.HasKey("ScriptID");

                    b.ToTable("Scripts");
                });

            modelBuilder.Entity("SilveRModel.Models.Analysis", b =>
                {
                    b.HasOne("SilveRModel.Models.Dataset", "Dataset")
                        .WithMany("Analysis")
                        .HasForeignKey("DatasetID")
                        .HasConstraintName("FK_Analyses_Datasets");

                    b.HasOne("SilveRModel.Models.Script", "Script")
                        .WithMany("Analysis")
                        .HasForeignKey("ScriptID")
                        .HasConstraintName("FK_Analyses_Scripts");
                });

            modelBuilder.Entity("SilveRModel.Models.Argument", b =>
                {
                    b.HasOne("SilveRModel.Models.Analysis", "Analysis")
                        .WithMany("Arguments")
                        .HasForeignKey("AnalysisID")
                        .HasConstraintName("FK_Arguments_Analyses")
                        .OnDelete(DeleteBehavior.Cascade);
                });
#pragma warning restore 612, 618
        }
    }
}
