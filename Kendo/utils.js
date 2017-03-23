//===========================================
// autosize column in grid
//===========================================
var grid = $("div[data-role='grid']").data('kendoGrid');
for (var i = 0; i < grid.columns.length; i++) {
	grid.autoFitColumn(i);
}

var gridElement = $("#wrapperMain"),
dataArea = gridElement.find(".k-grid-content");
dataArea.height(350);
grid.refresh();

//===========================================
// kendoDropDownList
//===========================================
var data = [
	{ text: "Black", value: "1" },
	{ text: "Orange", value: "2" },
	{ text: "Grey", value: "3" }
];

$("#color").kendoDropDownList({
	dataTextField: "text",
	dataValueField: "value",
	dataSource: data,
	index: 0,
	change: function(){  
		var value = $("#color").val();
		//TODO
	}
});

//===========================================
// kendoDatePicker
//===========================================
function ngaySXEditor(container, options) {
    $('<input required name="' + options.field + '"/>')
        .appendTo(container)
        .kendoDatePicker({
            parseFormats: ["dd/MM/yyyy"],
            format: "dd/MM/yyyy",
            value: new Date(),
            min: new Date(1950, 0, 1),
            max: new Date(2049, 11, 31)
        });
};