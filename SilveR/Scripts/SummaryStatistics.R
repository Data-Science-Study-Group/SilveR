#===================================================================================================================
#R Libraries

suppressWarnings(library(R2HTML))

#===================================================================================================================
# retrieve args

Args <- commandArgs(TRUE)

#Read in arguments
statdata <- read.csv(Args[3], header = TRUE, sep = ",")
csResponses <- Args[4]
transformation <- Args[5]
firstCat <- Args[6]
secondCat <- Args[7]
thirdCat <- Args[8]
fourthCat <- Args[9]
mean <- Args[10]
N <- Args[11]
StDev <- Args[12]
Variances <- Args[13]
StErr <- Args[14]
MinMax <- Args[15]
MedianQuartile <- Args[16]
CoeffVariation <- Args[17]
confidenceLimits <- Args[18]
CIval2 <- as.numeric(Args[19])
CIval <- CIval2 / 100
NormalProbabilityPlot <- Args[20]
ByCategoriesAndOverall <- Args[21]

#source(paste(getwd(),"/Common_Functions.R", sep=""))

#===================================================================================================================
#Graphics parameter setup

graphdata <- statdata

#===================================================================================================================
#Setup the html file and associated css file

htmlFile <- sub(".csv", ".html", Args[3]);
#determine the file name of the html file
HTMLSetFile(file = htmlFile)
.HTML.file = htmlFile

#===================================================================================================================
#Responses manipulation
#===================================================================================================================
#Breakdown the list of responses

resplist <- c()
tempChanges <- strsplit(csResponses, ",")
expectedChanges <- c(0)
for (i in 1:length(tempChanges[[1]])) {
    expectedChanges[length(expectedChanges) + 1] = (tempChanges[[1]][i])
}
for (j in 1:(length(expectedChanges) - 1)) {
    resplist[j] = expectedChanges[j + 1]
}
resplength <- length(resplist)

# Create the normal probability plot titles
resplistqq <- resplist

#replace illegal characters in variable names
for (i in 1:10) {
    resplistqq <- namereplace(resplistqq)
}

#===================================================================================================================
#Titles and description
#===================================================================================================================
#Module Title
Title <-paste(branding, " Summary Statistics", sep="")
HTML.title(Title, HR = 1, align = "left")
HTML.title("Analysis selection", HR=2, align="left")

add2<-c("Response")
if (length(expectedChanges) >2) {
	add2 <- paste(add2, "s", sep="")
} 
add2 <- paste(add2, " ", csResponses,  sep="")
if (length(expectedChanges) >2) {
	add2 <- paste(add2, " are", sep="")
} else {
	add2 <- paste(add2, " is", sep="")
}
add2 <- paste(add2, " analysed in this module", sep="")
if (firstCat != "NULL" || secondCat != "NULL" || thirdCat != "NULL" || fourthCat != "NULL") {
	add2 <- paste(add2, ", with results categorised by factor", sep="")
}
if ( (firstCat != "NULL" && secondCat != "NULL") || (firstCat != "NULL" && thirdCat != "NULL") || (firstCat != "NULL" && fourthCat != "NULL") || (secondCat != "NULL" && thirdCat != "NULL") || (secondCat != "NULL" && fourthCat != "NULL") || (thirdCat != "NULL" && fourthCat != "NULL") ) {
	add2 <- paste(add2, "s", sep="")
}
if (firstCat != "NULL") {
	add2 <- paste(add2, " ", firstCat, sep="")
}
if (secondCat != "NULL") {
	add2 <- paste(add2, ", ", secondCat, sep="")
}
if (thirdCat != "NULL") {
	add2 <- paste(add2, ", ", thirdCat, sep="")
}
if (fourthCat != "NULL") {
	add2 <- paste(add2, ", ", fourthCat, sep="")
}
if (transformation == "None")
{
	add2 <- paste(add2, ".", sep="")
} else {
	add2<-paste(add2, ". Response", sep="")
	if (length(expectedChanges) >2) {
		add2 <- paste(add2, "s", sep="")
	}
	add2<-paste(add2, " ", transformation, " transformed prior to analysis.", sep="")
}
HTML(add2, align="left")

#===================================================================================================================
#Categorisation analysis
#===================================================================================================================
if (firstCat != "NULL" || secondCat != "NULL" || thirdCat != "NULL" || fourthCat != "NULL") {
 
      #Overall title
      HTML.title("Categorised results", HR=2, align="left")
}

for (i in 1:resplength) {
	csResponses <- resplist[i]

        if (firstCat != "NULL" || secondCat != "NULL" || thirdCat != "NULL" || fourthCat != "NULL") {

            #Setting up parameters and vectors
            length <- length(unique(levels(as.factor(statdata$catfact))))
            tablenames <- c(levels(as.factor(statdata$catfact)))
            table <- c(1:length)
            for (i in 1:length) {
                table[i] = " "
            }

            vectormean <- c(1:length)
            vectorN <- c(1:length)
            vectorStDev <- c(1:length)
            vectorVariances <- c(1:length)
            vectorStErr <- c(1:length)
            vectorMin <- c(1:length)
            vectorMax <- c(1:length)
            vectorMedian <- c(1:length)
            vectorLQ <- c(1:length)
            vectorUQ <- c(1:length)
            vectorCoeffVariation <- c(1:length)
            vectorUCI <- c(1:length)
            vectorLCI <- c(1:length)


	    #Generating the summary stats
            for (i in 1:length) {
                sub <- subset(statdata, statdata$catfact == unique(levels(as.factor(statdata$catfact)))[i])
                sub2 <- data.frame(sub)
                if (mean == "Y") {
                    vectormean[i] = mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
                }
                if (N == "Y") {
                    tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                    vectorN[i] = length(tempy)
                }
                if (StDev == "Y") {
                    vectorStDev[i] = sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
                }
                if (Variances == "Y") {
                    vectorVariances[i] = var(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
                }
                if (StErr == "Y") {
                    tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                    vectorStErr[i] = sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / (length(tempy)) ** (0.5)
                }
                if (MinMax == "Y") {
                    vectorMin[i] = suppressWarnings(min(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE))
                }
                if (MinMax == "Y") {
                    vectorMax[i] = suppressWarnings(max(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE))
                }
                if (MedianQuartile == "Y") {
                    vectorMedian[i] = median(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
                }
                if (MedianQuartile == "Y") {
                    vectorLQ[i] = quantile(eval(parse(text = paste("sub2$", csResponses))), 0.25, type = 2, na.rm = TRUE)
                }
                if (MedianQuartile == "Y") {
                    vectorUQ[i] = quantile(eval(parse(text = paste("sub2$", csResponses))), 0.75, type = 2, na.rm = TRUE)
                }
                if (CoeffVariation == "Y") {
                    vectorCoeffVariation[i] = 100 * sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
                }
                if (confidenceLimits == "Y") {
                    tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                    vectorLCI[i] = mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) - qt(1 - (1 - CIval) / 2, (length(tempy) - 1)) * sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / (length(tempy)) ** (0.5)
                }
                if (confidenceLimits == "Y") {
                    tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                    vectorUCI[i] = mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) + qt(1 - (1 - CIval) / 2, (length(tempy) - 1)) * sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / (length(tempy)) ** (0.5)
                }
            }

            #Generating final table dataset
            if (mean == "Y") {
                vectormean <- format(round(vectormean, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectormean)
            }
            if (N == "Y") {
                #vectorN<-format(round(vectormean, 4), nsmall=4, scientific=FALSE)
                table <- cbind(table, vectorN)
            }
            if (StDev == "Y") {
                vectorStDev <- format(round(vectorStDev, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorStDev)
            }
            if (Variances == "Y") {
                vectorVariances <- format(round(vectorVariances, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorVariances)
            }
            if (StErr == "Y") {
                vectorStErr <- format(round(vectorStErr, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorStErr)
            }
            if (MinMax == "Y") {
                vectorMin <- format(round(vectorMin, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorMin)
            }
            if (MinMax == "Y") {
                vectorMax <- format(round(vectorMax, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorMax)
            }
            if (MedianQuartile == "Y") {
                vectorMedian <- format(round(vectorMedian, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorMedian)
            }
            if (MedianQuartile == "Y") {
                vectorLQ <- format(round(vectorLQ, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorLQ)
            }
            if (MedianQuartile == "Y") {
                vectorUQ <- format(round(vectorUQ, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorUQ)
            }
            if (CoeffVariation == "Y") {
                vectorCoeffVariation <- format(round(vectorCoeffVariation, 1), nsmall = 1, scientific = FALSE)
                table <- cbind(table, vectorCoeffVariation)
            }
            if (confidenceLimits == "Y") {
                vectorLCI <- format(round(vectorLCI, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorLCI)
            }
            if (confidenceLimits == "Y") {
                vectorUCI <- format(round(vectorUCI, 4), nsmall = 4, scientific = FALSE)
                table <- cbind(table, vectorUCI)
            }

            #Generating column names
            temp6 <- c("Categorisation Factor levels")
            if (mean == "Y") {
                hed1 <- c("Mean")
                temp6 <- cbind(temp6, hed1)
            }
            if (N == "Y") {
                hed2 <- c("N")
                temp6 <- cbind(temp6, hed2)
            }
            if (StDev == "Y") {
                #STB May 2012 changing header
                hed3 <- c("Std dev")
                temp6 <- cbind(temp6, hed3)
            }
            if (Variances == "Y") {
                hed4 <- c("Variance")
                temp6 <- cbind(temp6, hed4)
            }
            if (StErr == "Y") {
                #STB May 2012 changing header
                hed5 <- c("Std error")
                temp6 <- cbind(temp6, hed5)
            }
            if (MinMax == "Y") {
                hed6 <- c("Min")
                temp6 <- cbind(temp6, hed6)
            }
            if (MinMax == "Y") {
                hed7 <- c("Max")
                temp6 <- cbind(temp6, hed7)
            }
            if (MedianQuartile == "Y") {
                hed8 <- c("Median")
                temp6 <- cbind(temp6, hed8)
            }
            if (MedianQuartile == "Y") {
                hed9 <- c("Lower quartile")
                temp6 <- cbind(temp6, hed9)
            }
            if (MedianQuartile == "Y") {
                hed10 <- c("Upper quartile")
                temp6 <- cbind(temp6, hed10)
            }
            if (CoeffVariation == "Y") {
                hed11 <- c("%CV")
                temp6 <- cbind(temp6, hed11)
            }
            if (confidenceLimits == "Y") {
                CIlow <- paste("Lower ", 100 * CIval, sep = "")
                CIlow <- paste(CIlow, "% CI", sep = "")
                hed12 <- c(CIlow)
                temp6 <- cbind(temp6, hed12)
            }
            if (confidenceLimits == "Y") {
                CIhigh <- paste("Upper ", 100 * CIval, sep = "")
                CIhigh <- paste(CIhigh, "% CI", sep = "")
                hed13 <- c(CIhigh)
                temp6 <- cbind(temp6, hed13)
            }

  	    #Generating row names
            rownms <- c(" ")
            for (i in 1:length) {
                rownms[i] <- levels(as.factor(statdata$catfact))[i]
            }
	    table <- table[,-1]
            table <- cbind(rownms, table)
            colnames(table) <- temp6

            #Generating title for the tables
            add <- paste(c("Summary statistics for "), csResponses, sep = "")
            add <- paste(add, " categorised by ", sep = "")

            if (firstCat != "NULL" && secondCat == "NULL" && thirdCat == "NULL" && fourthCat == "NULL") {
                add <- paste(add, firstCat, sep = "")
            } 
	    if (firstCat == "NULL" && secondCat != "NULL" && thirdCat == "NULL" && fourthCat == "NULL") {
                add <- paste(add, secondCat, sep = "")
            } 
            if (firstCat == "NULL" && secondCat == "NULL" && thirdCat != "NULL" && fourthCat == "NULL") {
                add <- paste(add, thirdCat, sep = "")
            } 
            if (firstCat == "NULL" && secondCat == "NULL" && thirdCat == "NULL" && fourthCat != "NULL") {
                add <- paste(add, fourthCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat != "NULL" && thirdCat == "NULL" && fourthCat == "NULL") {
                add <- paste(add, firstCat, " and ", secondCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat == "NULL" && thirdCat != "NULL" && fourthCat == "NULL") {
                add <- paste(add, firstCat, " and ", thirdCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat == "NULL" && thirdCat == "NULL" && fourthCat != "NULL") {
                add <- paste(add, firstCat, " and ", fourthCat, sep = "")
            }
            if (firstCat == "NULL" && secondCat != "NULL" && thirdCat != "NULL" && fourthCat == "NULL") {
                add <- paste(add, secondCat, " and ", thirdCat, sep = "")
            }
            if (firstCat == "NULL" && secondCat != "NULL" && thirdCat == "NULL" && fourthCat != "NULL") {
                add <- paste(add, secondCat, " and ", fourthCat, sep = "")
            }
            if (firstCat == "NULL" && secondCat == "NULL" && thirdCat != "NULL" && fourthCat != "NULL") {
                add <- paste(add, thirdCat, " and ", fourthCat, sep = "")
            }
            if (firstCat == "NULL" && secondCat != "NULL" && thirdCat != "NULL" && fourthCat != "NULL") {
                add <- paste(add, secondCat, ", ", thirdCat, " and ", fourthCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat != "NULL" && thirdCat != "NULL" && fourthCat == "NULL") {
               add <- paste(add, firstCat, ", ", secondCat, " and ", thirdCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat != "NULL" && thirdCat == "NULL" && fourthCat != "NULL") {
               add <- paste(add, firstCat, ", ", secondCat, " and ", fourthCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat == "NULL" && thirdCat != "NULL" && fourthCat != "NULL") {
               add <- paste(add, firstCat, ", ", thirdCat, " and ", fourthCat, sep = "")
            }
            if (firstCat != "NULL" && secondCat != "NULL" && thirdCat != "NULL" && fourthCat != "NULL") {
               add <- paste(add, firstCat, ", ", secondCat, ", ", thirdCat, " and ", fourthCat, sep = "")
            }

            #Output tables 
            HTML(add, align = "left")
            HTML(table, align = "left", classfirstline = "second", row.names = "FALSE")
	}
}

#===================================================================================================================
#Non-categorisation analysis
#===================================================================================================================
if ((firstCat != "NULL" || secondCat != "NULL" || thirdCat != "NULL" || fourthCat != "NULL") && ByCategoriesAndOverall == "Y") {

        #Overall title
        HTML.title("Non-categorised results", HR=2, align="left")
}

if ((firstCat == "NULL" && secondCat == "NULL" && thirdCat == "NULL" && fourthCat == "NULL") ) {

        #Overall title
        HTML.title("Results", HR=2, align="left")
}

for (i in 1:resplength) {

   if ((firstCat == "NULL" && secondCat == "NULL" && thirdCat == "NULL" && fourthCat == "NULL") || ByCategoriesAndOverall == "Y") {

	csResponses <- resplist[i]

	#Setting up parameters and vectors
	length <- 1
        table <- c(1:1)
        table[1] <- csResponses

        vectormean <- c(1:length)
        vectorN <- c(1:length)
        vectorStDev <- c(1:length)
        vectorVariances <- c(1:length)
        vectorStErr <- c(1:length)
        vectorMin <- c(1:length)
        vectorMax <- c(1:length)
        vectorMedian <- c(1:length)
        vectorLQ <- c(1:length)
        vectorUQ <- c(1:length)
        vectorCoeffVariation <- c(1:length)
        vectorUCI <- c(1:length)
        vectorLCI <- c(1:length)

        #Generating summary statistics
        for (i in 1:length) {
            sub <- statdata
            sub2 <- data.frame(sub)

            if (mean == "Y") {
                vectormean[i] = mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
            }
            if (N == "Y") {
                tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                vectorN[i] = length(tempy)
            }
            if (StDev == "Y") {
                vectorStDev[i] = sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
            }
            if (Variances == "Y") {
                vectorVariances[i] = var(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
            }
            if (StErr == "Y") {
                tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                vectorStErr[i] = sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / (length(tempy)) ** (0.5)
            }
            if (MinMax == "Y") {
                vectorMin[i] = suppressWarnings(min(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE))
            }
            if (MinMax == "Y") {
                vectorMax[i] = suppressWarnings(max(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE))
            }
            if (MedianQuartile == "Y") {
                vectorMedian[i] = median(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
            }
            if (MedianQuartile == "Y") {
                vectorLQ[i] = quantile(eval(parse(text = paste("sub2$", csResponses))), 0.25, type = 2, na.rm = TRUE)
            }
            if (MedianQuartile == "Y") {
                vectorUQ[i] = quantile(eval(parse(text = paste("sub2$", csResponses))), 0.75, type = 2, na.rm = TRUE)
            }
            if (CoeffVariation == "Y") {
                vectorCoeffVariation[i] = 100 * sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE)
            }
            if (confidenceLimits == "Y") {
                tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                vectorLCI[i] = mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) - qt(1 - (1 - CIval) / 2, (length(tempy) - 1)) * sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / (length(tempy)) ** (0.5)
            }
            if (confidenceLimits == "Y") {
                tempy <- na.omit(eval(parse(text = paste("sub2$", csResponses))))
                vectorUCI[i] = mean(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) + qt(1 - (1 - CIval) / 2, (length(tempy) - 1)) * sd(eval(parse(text = paste("sub2$", csResponses))), na.rm = TRUE) / (length(tempy)) ** (0.5)
            }
        }

        #Generating final table dataset
        if (mean == "Y") {
             vectormean <- format(round(vectormean, 4), nsmall = 4, scientific = FALSE)
             table <- cbind(table, vectormean)
        }
        if (N == "Y") {
            table <- cbind(table, vectorN)
        }
        if (StDev == "Y") {
            vectorStDev <- format(round(vectorStDev, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorStDev)
        }
        if (Variances == "Y") {
            vectorVariances <- format(round(vectorVariances, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorVariances)
        }
        if (StErr == "Y") {
            vectorStErr <- format(round(vectorStErr, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorStErr)
        }
        if (MinMax == "Y") {
            vectorMin <- format(round(vectorMin, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorMin)
        }
        if (MinMax == "Y") {
            vectorMax <- format(round(vectorMax, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorMax)
        }
        if (MedianQuartile == "Y") {
            vectorMedian <- format(round(vectorMedian, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorMedian)
        }
        if (MedianQuartile == "Y") {
            vectorLQ <- format(round(vectorLQ, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorLQ)
        }
        if (MedianQuartile == "Y") {
            vectorUQ <- format(round(vectorUQ, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorUQ)
        }
        if (CoeffVariation == "Y") {
            vectorCoeffVariation <- format(round(vectorCoeffVariation, 1), nsmall = 1, scientific = FALSE)
            table <- cbind(table, vectorCoeffVariation)
        }
        if (confidenceLimits == "Y") {
            vectorLCI <- format(round(vectorLCI, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorLCI)
        }
        if (confidenceLimits == "Y") {
            vectorUCI <- format(round(vectorUCI, 4), nsmall = 4, scientific = FALSE)
            table <- cbind(table, vectorUCI)
        }

        #creating final output table

        #Generating column names
        temp6 <- c("Response")

        if (mean == "Y") {
            hed1 <- c("Mean")
            temp6 <- cbind(temp6, hed1)
        }
        if (N == "Y") {
            hed2 <- c("N")
            temp6 <- cbind(temp6, hed2)
        }
        if (StDev == "Y") {
            #STB May 2012 changing header
            hed3 <- c("Std dev")
            temp6 <- cbind(temp6, hed3)
        }
        if (Variances == "Y") {
            hed4 <- c("Variance")
            temp6 <- cbind(temp6, hed4)
        }
        if (StErr == "Y") {
            #STB May 2012 changing header
            hed5 <- c("Std error")
            temp6 <- cbind(temp6, hed5)
        }
        if (MinMax == "Y") {
            hed6 <- c("Min")
            temp6 <- cbind(temp6, hed6)
        }
        if (MinMax == "Y") {
            hed7 <- c("Max")
            temp6 <- cbind(temp6, hed7)
        }
        if (MedianQuartile == "Y") {
            hed8 <- c("Median")
            temp6 <- cbind(temp6, hed8)
        }
        if (MedianQuartile == "Y") {
            hed9 <- c("Lower quartile")
            temp6 <- cbind(temp6, hed9)
        }
        if (MedianQuartile == "Y") {
            hed10 <- c("Upper quartile")
            temp6 <- cbind(temp6, hed10)
        }
        if (CoeffVariation == "Y") {
            hed11 <- c("%CV")
            temp6 <- cbind(temp6, hed11)
        }
        if (confidenceLimits == "Y") {
            CIlow <- paste("Lower ", 100 * CIval, sep = "")
            CIlow <- paste(CIlow, "% CI", sep = "")
            hed12 <- c(CIlow)
            temp6 <- cbind(temp6, hed12)
        }
        if (confidenceLimits == "Y") {
            CIhigh <- paste("Upper ", 100 * CIval, sep = "")
            CIhigh <- paste(CIhigh, "% CI", sep = "")
            hed13 <- c(CIhigh)
            temp6 <- cbind(temp6, hed13)
        }

        #Generating row names
        colnames(table) <- temp6

        #Output print
        if ((firstCat == "NULL" && secondCat == "NULL" && thirdCat == "NULL" && fourthCat == "NULL")) {
            add <- paste(c("Summary statistics for "), csResponses, sep = "")
            HTML(add, align = "left")
         } else
         if ((firstCat != "NULL" || secondCat != "NULL" || thirdCat != "NULL" || fourthCat != "NULL") && ByCategoriesAndOverall == "Y") {
             add <- paste(c("Overall summary statistics, ignoring the categorisation factor(s), for "), csResponses, sep = "")
             HTML(add, align = "left")
         }
         HTML(table, align = "left", classfirstline = "second", row.names = "FALSE")
    }
}

#===================================================================================================================
#Normal probability plot
#===================================================================================================================
if (NormalProbabilityPlot != "N") {
    HTML.title("Normal probability plot", HR = 1, align = "left")

#===================================================================================================================
    #Graphical plot options
    YAxisTitle <- "Sample Quantiles"
    XAxisTitle <- "Theoretical Quantiles"
    w_Gr_jit <- 0
    h_Gr_jit <- 0
    infiniteslope <- "N"
    LinearFit <- "Y"
    Line_size <- 0.5
    Gr_alpha <- 1
    Line_type <- Line_type_dashed
    ScatterPlot <- "Y"
#===================================================================================================================
    index <- 1
 
    for (i in 1: (length(expectedChanges)-1)) {
	normPlot <- sub(".html", "IVS", htmlFile)
    	normPlot <- paste(normPlot, index, "normplot.jpg", sep = "")
    	jpeg(normPlot, width = jpegwidth, height = jpegheight, quality = 100)

    	#STB July2013
    	plotFilepdf4 <- sub(".html", "IVS", htmlFile)
    	plotFilepdf4 <- paste(plotFilepdf4, index, "normplot.pdf", sep = "")
    	dev.control("enable")

    	csResponses <- resplist[index]
    	csResponsesqq <- resplistqq[index]
    	adda <- paste(c("Normal probability plot for "), csResponsesqq, " \n", sep = "")
    	MainTitle2 <- adda
    	te <- qqnorm(eval(parse(text = paste("statdata$", csResponses))))
    	graphdata <- data.frame(te$x, te$y)
    	graphdata$xvarrr_IVS <- graphdata$te.x
    	graphdata$yvarrr_IVS <- graphdata$te.y

    	#GGPLOT2 code
    	NONCAT_SCAT("QQPLOT")
#===================================================================================================================
    	void <- HTMLInsertGraph(GraphFileName = sub("[A-Z0-9a-z,:,\\\\]*App_Data[\\\\]", "", normPlot), Align = "left")

    	#STB July2013
    	if (pdfout == "Y") {
        	pdf(file = sub("[A-Z0-9a-z,:,\\\\]*App_Data[\\\\]", "", plotFilepdf4), height = pdfheight, width = pdfwidth)
        	dev.set(2)
        	dev.copy(which = 3)
        	dev.off(2)
        	dev.off(3)
        	pdfFile_4 <- sub("[A-Z0-9a-z,:,\\\\]*App_Data[\\\\]", "", plotFilepdf4)
        	linkToPdf4 <- paste("<a href=\"", pdfFile_4, "\">Click here to view the PDF of the normal probability plot</a>", sep = "")
        	HTML(linkToPdf4)
    	}

	index <- index +1
     }

     HTML("Tip: Check that the points lie along the dotted line. If not then the data may be non-normally distributed.", align="left")
     HTML("Warning: Note the normal probability plots presented in the Summary Statistics module do not take into account any design factors. Hence the response(s) may appear to be non-normally distributed due to the effect of any design factors. If you have factors that may influence the response(s), then it is recommended that you use the normal probability plot in the Single or Repeated Measures Parametric Analysis module, which does take these factors into account.", align="left")
}

#===================================================================================================================
#References
#===================================================================================================================
Ref_list <- R_refs()

#Bate and Clark comment
HTML(refxx, align = "left")

HTML.title("Statistical references", HR = 2, align = "left")
HTML(Ref_list$BateClark_ref, align = "left")

HTML.title("R references", HR = 2, align = "left")
HTML(Ref_list$R_ref, align = "left")
HTML(Ref_list$GGally_ref,  align = "left")
HTML(Ref_list$RColorBrewers_ref, align = "left")
HTML(Ref_list$GGPLot2_ref,align = "left")
HTML(Ref_list$reshape_ref,  align = "left")
HTML(Ref_list$plyr_ref,  align = "left")
HTML(Ref_list$scales_ref,  align = "left")
HTML(Ref_list$R2HTML_ref,  align = "left")
HTML(Ref_list$PROTO_ref,  align = "left")

#===================================================================================================================
#Show dataset
#===================================================================================================================
if (showdataset == "Y") {

    observ <- data.frame(c(1:dim(statdata)[1]))
    colnames(observ) <- c("Observation")
    statdata <- cbind(observ, statdata)
    statdata2 <- subset(statdata, select = -c(catfact))

    HTML.title("Analysis dataset", HR = 2, align = "left")
    HTML(statdata2, classfirstline = "second", align = "left", row.names = "FALSE")
}

#===================================================================================================================
#Show arguments
#===================================================================================================================
HTML.title("Analysis options", HR=2, align="left")

HTML(paste("Response variables: ", csResponses, sep=""),  align="left")

if (transformation != "None") {
	HTML(paste("Response variables transformation: ", transformation, sep=""),  align="left")
}

if (firstCat != "NULL") {
	HTML(paste("First categorisation factor: ", firstCat, sep=""),  align="left")
}

if (secondCat != "NULL") {
	HTML(paste("Second categorisation factor: ", secondCat, sep=""),  align="left")
}

if (thirdCat != "NULL") {
	HTML(paste("Third categorisation factor: ", thirdCat, sep=""),  align="left")
}

if (fourthCat != "NULL") {
	HTML(paste("Fourth categorisation factor: ", fourthCat, sep=""),  align="left")
}
HTML(paste("Display mean (Y/N): ", mean, sep=""),  align="left")
HTML(paste("Display sample size  (Y/N): ", N, sep=""),  align="left")
HTML(paste("Display standard deviation (Y/N): ", StDev, sep=""),  align="left")
HTML(paste("Display variance (Y/N): ", Variances, sep=""),  align="left")
HTML(paste("Display standard error (Y/N): ", StErr, sep=""),  align="left")
HTML(paste("Display minimum/maximum  (Y/N): ", MinMax, sep=""),  align="left")
HTML(paste("Display median and quartiles (Y/N): ", MedianQuartile, sep=""),  align="left")
HTML(paste("Display coefficient of variation (Y/N): ", CoeffVariation, sep=""),  align="left")
HTML(paste("Display confidence interval (Y/N): ", confidenceLimits, sep=""),  align="left")

if (confidenceLimits == "Y") {	
	HTML(paste("Confidence level: ", CIval2, sep=""),  align="left")
}

HTML(paste("Display normal probability plot (Y/N): ", NormalProbabilityPlot, sep=""),  align="left")
HTML(paste("Display results by categories & overall (Y/N): ", ByCategoriesAndOverall, sep=""),  align="left")