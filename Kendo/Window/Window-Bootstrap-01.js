function onResizeWindow(e){
	if(e != undefined){
		$('.k-tabstrip .k-content').each(function(){
			$(this).css('height', e.height - 110 );
		});
	}else{
		$('.k-tabstrip .k-content').each(function(){
			$(this).css('height', (Screen().height/1.3) - 110 );
		});
	}
}

var vModel = kendo.observable({
	oWin: null,
	options: { isVisible: true, data: null, parentData: null, frmSaving: false },
	onInit: function(oWin, Opts){
		this.oWin = oWin;
		this.options = $.extend({}, this.options, Opts);
		
		this.oWin.center().open();
		setTimeout(function(){ onResizeWindow(); } , 500);
		$('input[type="checkbox"]').on('change', function() {
		   $('input[type="checkbox"]').not(this).prop('checked', false);
		});
		
		var txtNgaysinh = $("#txtNgaysinh").kendoDatePicker({
								value: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
								parseFormats: ["dd/MM/yyyy"],
								format: "dd/MM/yyyy",
								change: function () {}
							}).data("kendoDatePicker");
		var txtVaolam = $("#txtVaolam").kendoDatePicker({
								value: new Date(new Date().getFullYear(), new Date().getMonth(), 1),
								parseFormats: ["dd/MM/yyyy"],
								format: "dd/MM/yyyy",
								change: function () {}
							}).data("kendoDatePicker");					


		
		this.onInitToolbar();
		this.onInitTab();
	},
	//button + togglable events
	togglableEvt: function(e){ 
		alert($(e.target).attr('id')); return false;
		switch($(e.target).attr('id')){
			case "btnToggle": alert('btnToggle'); break;
		}
	},
	buttonEvt: function(e){
		var v_id = $(e.target).attr('id');
		if(v_id == undefined){
			v_id = $(e.target).parent().attr('id');
		}
		alert(v_id);  return false;
		switch($(e.target).attr('id')){
			case "btn_Button": alert('btnMyEdit'); break;
		}
	},
	//end button + togglable events
	
	onChange: function() {
		//console.log("event :: change (" + kendo.htmlEncode(this.get("data.firstname")) + ")");
	},
	onInitTab: function(){
		$("#tabstrip-bottom").kendoTabStrip({
			tabPosition: "bottom",
			animation: { open: { effects: "fadeIn" } }
		});
	},
	
	onInitToolbar: function(){
		var itemToolbar = [
			{ id: 'btn_Button', type: "button", text: "Button", spriteCssClass: "myEditIcon", click: this.buttonEvt },
			{ id: 'btn_Toggle_Button', type: "button", text: "Toggle Button", togglable: true, toggle: this.togglableEvt },
			{
				type: "splitButton",
				text: "Insert",
				menuButtons: [
					{ id: 'btn_Insert_above', text: "Insert above", icon: "insert-up", click: this.buttonEvt },
					{ id: 'btn_Insert_between', text: "Insert between", icon: "insert-middle", click: this.buttonEvt },
					{ id: 'btn_Insert_below', text: "Insert below", icon: "insert-down", click: this.buttonEvt }
				]
			},
			{ type: "separator" },
			{ template: "<label>Format:</label>" },
			{
				template: "<input id='dropdown' style='width: 150px;' />",
				overflow: "never"
			},
			{ type: "separator" },
			{
				type: "buttonGroup",
				buttons: [
					{ id: 'btn_leftTogglable', icon: "align-left", text: "Left", togglable: true, group: "text-align", toggle: this.togglableEvt },
					{ id: 'btn_centerTogglable', icon: "align-center", text: "Center", togglable: true, group: "text-align", toggle: this.togglableEvt },
					{ id: 'btn_rightTogglable', icon: "align-right", text: "Right", togglable: true, group: "text-align", toggle: this.togglableEvt }
				]
			},
			{
				type: "buttonGroup",
				buttons: [
					{ id: 'btn_boldTogglable', icon: "bold", text: "Bold", togglable: true, showText: "overflow", toggle: this.togglableEvt },
					{ id: 'btn_italicTogglable', icon: "italic", text: "Italic", togglable: true, showText: "overflow", toggle: this.togglableEvt },
					{ id: 'btn_underlineTogglable', icon: "underline", text: "Underline", togglable: true, showText: "overflow", toggle: this.togglableEvt }
				]
			},
			{ id: 'btn_Action', type: "button", text: "Action", overflow: "always", click: this.buttonEvt },
			{ id: 'btn_Another_Action', type: "button", text: "Another Action", overflow: "always", click: this.buttonEvt },
			{ id: 'btn_Something_else_here', type: "button", text: "Something else here", overflow: "always", click: this.buttonEvt }
		];
		$("#toolbar").kendoToolBar({ items: itemToolbar });
		$("#dropdown").kendoDropDownList({
			optionLabel: "Paragraph",
			dataTextField: "text",
			dataValueField: "value",
			dataSource: [
				{ text: "Heading 1", value: 1 },
				{ text: "Heading 2", value: 2 },
				{ text: "Heading 3", value: 3 },
				{ text: "Title", value: 4 },
				{ text: "Subtitle", value: 5 }
			]
		});
	},
	checkValidation: function(){
	  var validator = $("#ticketsForm").kendoValidator().data("kendoValidator");
	  return validator.validate();
	},
	btnSave_Click: function(){
	  if(this.checkValidation()){
		alert('okie');
	  }
	},
	btnCancel_Click: function(){ this.oWin.destroy(); }
});