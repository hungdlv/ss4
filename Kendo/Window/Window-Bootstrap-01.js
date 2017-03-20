var viewAddModel = kendo.observable({
	isVisible: true,
	oWin: null,
	data: null,
	onInit: function(oWin){
		this.data = {
			id: 0,
			firstname: '', 
			lastname: ''
		  };
	  this.oWin = oWin;
	  this.onInitToolbar();
	  this.onInitTab();
	},
	onChange: function() {
		console.log("event :: change (" + kendo.htmlEncode(this.get("data.firstname")) + ")");
	},
	onInitTab: function(){
		
	},
	itemToolbar: [],
	onInitToolbar: function(){
		
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
	btnCancel_Click: function(){
		//alert('cancel');
	  //this.oWin.destroy();
	  //"info", "success", "warning" and "error"
	  //this.shwNotification('Bạn đã cập nhật thành công', 'info');
	}
});