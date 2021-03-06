﻿
$(function () {

    $("#Responses").kendoMultiSelect({
        dataSource: theModel.availableVariables,
        value: theModel.responses
    });

    $("#Transformation").kendoDropDownList({
        dataSource: theModel.transformationsList
    });

    $("#FirstCatFactor").kendoDropDownList({
        dataSource: theModel.availableVariablesAllowNull
    });

    $("#SecondCatFactor").kendoDropDownList({
        dataSource: theModel.availableVariablesAllowNull
    });

    $("#ThirdCatFactor").kendoDropDownList({
        dataSource: theModel.availableVariablesAllowNull
    });

    $("#FourthCatFactor").kendoDropDownList({
        dataSource: theModel.availableVariablesAllowNull
    });

    $("#Significance").kendoNumericTextBox({
        format: '#.#',
        decimals: 1,
        spinners: true
    });
});