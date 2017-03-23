
//Kiểm tra trong tháng/năm có bao nhiêu ngày
function daysInMonth(month, year) { return new Date(year, month, 0).getDate(); }

var ss4 = ss4 || { 'settings': {}, 'behaviors': {}, 'locale': {}, 'easyui': {} };
    (function ($) {
        //api
        var IGNORE_ERROR = 'ignore_error';
        ss4.isArray = function (ob) { return ob.constructor === Array; }
        ss4.getParam = function (obj, default_value) {
            if (typeof obj === 'undefined' || obj == null || obj == 'null') {
                if (typeof default_value === 'undefined')
                    return null;
                return default_value;
            }
            return obj;
        };
        ss4.getFileExtension = function (filename) {
            var ext = /^.+\.([^.]+)$/.exec(filename);
            return ext == null ? "" : ext[1];
        };
        ss4.getSizeUpload = function (elID) {
            var size = document.getElementById(elID).files[0].size;
            if (size < 1024) return "<br>(<strong> " + size.toString() + "B</strong> )";
            else if (size < 1024 * 1024) return "<br>(<strong> " + parseInt((size / 1024)).toString() + "KB</strong> )";
            else if (size < 1024 * 1024 * 1024) return "<br>(<strong> " + parseInt((size / 1024 / 1024)).toString() + "MB</strong> )";
            else return "<br>(<strong> " + parseInt((size / 1024 / 1024 / 1024).toString()) + "GB</strong> )";
        };
        ss4.clsApi = function (param) {
            var thisObj = this;

            this.request = function (url, onCompleteFn, onErrorFn, data_options, retry_count) {
                if (url == '') {
                    onCompleteFn(data_options.result);
                    return;
                }
                if (!ss4.getParam(data_options)) {
                    data_options = {
                        type: 'POST',
                        dataType: 'json',
                        timeout: 10000,
                        auto_disable: true, // Tự động disable page khi load ajax
                        auto_enable: true, // Tự động enable page sau khi load ajax xong
                        data: {},
                        error_message: 'Lỗi kết nối',
                        waiting_message: 'Vui lòng đợi',
                        bshowwaiting: true
                    }
                } else {
                    if (!ss4.getParam(data_options.data))
                        data_options.data = {};
                    //if (!ss4.getParam(data_options.bshowwaiting))
                    if (data_options.bshowwaiting == undefined)
                        data_options.bshowwaiting = true;
                }

                // add version to url
                retry_count = ss4.getParam(retry_count, 1);
                //get userAgent
                //data_options.data.userAgent = navigator.userAgent;
                // add timestamp in dataoptions
                data_options.data.ss4id = ss4.getRandom(10, 999999999);

                if (data_options.bshowwaiting)
                    ss4.Loading(true, ss4.getParam(data_options.waiting_message, 'Vui lòng đợi...'));
                is_ajax = true;
                $.ajax({
                    cache: false,
                    //async: ss4.getParam(data_options.async, true),
                    type: ss4.getParam(data_options.type, 'POST'),
                    url: url,
                    dataType: ss4.getParam(data_options.dataType, 'json'),
                    timeout: ss4.getParam(data_options.timeout, 500000),
                    data: ss4.getParam(data_options.data),
                    error: function (xhr, ajaxOptions, thrownError) {
                        if (retry_count == 3) {
                            ss4.Loading(false, ss4.getParam(data_options.waiting_message, 'Vui lòng đợi...'));
                            is_ajax = false;

                            var msg = ss4.getParam(data_options.error_message, 'Lỗi kết nối');
                            if (msg == IGNORE_ERROR) {
                                if (ss4.getParam(onErrorFn))
                                    onErrorFn();
                            } else {
                                msg += ' Trạng thái: ' + xhr.status + '. Lỗi : ' + thrownError;
                                //alert(msg);
                                console.log('ERROR:' + msg);
                            }
                        } else {
                            //retry_count++;
                            //thisObj.request(url, onCompleteFn, onErrorFn, data_options, retry_count);
                        }
                    },
                    success: function (stringdata) {
                        is_ajax = false;
                        if (data_options.bshowwaiting)
                            ss4.Loading(false, ss4.getParam(data_options.waiting_message, 'Vui lòng đợi...'));

                        if (stringdata) {
                            if (ss4.isArray(stringdata)) {
                                if ((stringdata.length > 0) || !ss4.getParam(data_options.onNothingFoundFn)) {
                                    if (onCompleteFn)
                                        onCompleteFn(stringdata);
                                } else {
                                    if (ss4.getParam(data_options.onNothingFoundFn))
                                        data_options.onNothingFoundFn();
                                }
                            } else {
                                if (onCompleteFn)
                                    onCompleteFn(stringdata);
                            }
                        } else if (ss4.getParam(data_options.onNothingFoundFn))
                            data_options.onNothingFoundFn();
                        else if (onCompleteFn)
                            onCompleteFn(stringdata);

                        if (ss4.getParam(data_options.onFinalFn))
                            data_options.onFinalFn();
                    }
                });

            };
        };

        //utilities
        ss4.Screen = function () { return { width: $(window).width(), height: $(window).height() }; };
        ss4.Loading = function (bshow) {
            bshow = bshow || false;
            ss4.shwProgress(bshow, { title: 'Đang xử lý dữ liệu', msg: 'Vui lòng đợi trong giây lát....', interval: 200 });
            /*
            if (bshow) {
                if ($('.loadercontainer').length == 0)
                    $('body').append('<div class="loadercontainer"><div class="ss4loading"></div><span>Vui lòng đợi...</span></div><div id="bgOpacity"></div>');
                $('#bgOpacity').fadeIn(500);
                $('.loadercontainer').fadeIn(500);                
                var screenWindow = ss4.Screen();
                var widthLoading = parseInt($('.loadercontainer').css('width')) / 2;
                $('.loadercontainer').css('top', screenWindow.height / 2).css('right', (screenWindow.width / 2) - widthLoading);
            } else {
                $('.loadercontainer').fadeOut(500); $('#bgOpacity').fadeOut(500);                
            }*/
        };
        ss4.getObjToFieldArray = function (obj) {
            var arr = [];
            for (var p in obj) {
                if (obj.hasOwnProperty(p)) {
                    arr.push({ field: p });
                }
            }
            return arr;
        };
        ss4.htmlspecialchars = function (str) {
            if (typeof (str) == "string") {
                str = str.replace(/&/g, "&amp;"); /* must do &amp; first */
                str = str.replace(/"/g, "&quot;");
                str = str.replace(/'/g, "&#039;");
                str = str.replace(/</g, "&lt;");
                str = str.replace(/>/g, "&gt;");
            }
            return str;
        };
        ss4.rhtmlspecialchars = function (str) {
            if (typeof (str) == "string") {
                str = str.replace(/&gt;/ig, ">");
                str = str.replace(/&lt;/ig, "<");
                str = str.replace(/&#039;/g, "'");
                str = str.replace(/&quot;/ig, '"');
                str = str.replace(/&amp;/ig, '&'); /* must do &amp; last */
            }
            return str;
        };
        ss4.extraAccount = function (newoptions) {
            var options = { targetId: '' };
            options = $.extend({}, options, newoptions);

            if ($('#dlgExtraAccount').length == 0) {
                $('body').append(
                    '<div id="dlgExtraAccount" class="form-ul" data-options="iconCls:\'icon-mail\',modal:true,minimizable:false,maximizable:false,collapsible:false,draggable:true,resizable:false" class="extjsui-window" style="width: 420px; height: 225px;" closed="true" buttons="#dlg-buttons-extraAccount">' +
                        '<ul style="margin:5px;"><li>Nhập tên tài khoản</li><li><input type="textbox" class="textbox" id="txtSearchAccount" style="margin:0px 5px;"></li><input type="button" value="Tìm kiếm" onclick="clsApi.request(\'/home/sampleDomain\', function (response) { $(\'#dataGridAccount\').datagrid(\'loadData\', response); }, function () { }, { data: { \'account\': $(\'#txtSearchAccount\').val() } });"></li></ul>' +
                        '<div style="margin:5px;"><div id="dataGridAccount"></div></div>' +
                        '<div id="dlg-buttons-extraAccount">' +
                            '<input type="button" style="margin:0px 10px;" value="Chọn tài khoản" onclick="' +
                             ' var arrAccount = $(\'#dataGridAccount\').datagrid(\'getSelections\'); ' +
                             ' var sOldToEmail = $(\'#' + options.targetId + '\').textbox(\'getValue\'); ' +
                             ' var sNewToEmail = \'\';' +
                             ' for(var i=0; i< arrAccount.length; i++){ if(sNewToEmail == \'\'){ sNewToEmail = arrAccount[i].mail; } else{ sNewToEmail += \',\' + arrAccount[i].mail; }  }' +
                             ' if(sOldToEmail == \'\'){ sOldToEmail = sNewToEmail; } else{ sOldToEmail = sOldToEmail + \',\' +  sNewToEmail } ' +
                             ' $(\'#' + options.targetId + '\').textbox(\'setValue\', sOldToEmail); ' +
                             'jQuery(\'#dlgExtraAccount\').dialog(\'close\');' +
                            '">' +
                            '<input type="button" style="" value="Bỏ qua" onclick="javascript:jQuery(\'#dlgExtraAccount\').dialog(\'close\')">' +
                        '</div>' +
                    '</div>');


                var __objInitGrid = {
                    //title: 'Danh sách tài khoản',
                    //iconCls: 'icon-edit',
                    width: '100%',
                    height: 180,
                    singleSelect: false,
                    idField: 'mail',
                    modal: true,
                    columns: [[
                        { field: 'displayname', title: 'Họ tên', width: 200 },
                        { field: 'mail', title: 'Email', width: 200 },
                        { field: 'title', title: 'Chức danh', width: 200 },
                        { field: 'company', title: 'Phòng ban', width: 150 }
                    ]],
                    onDblClickRow: function (index, row) {
                        var sOldToEmail = $('#' + options.targetId).textbox('getValue');
                        var sNewToEmail = row.mail;
                        if (sOldToEmail == '') { sOldToEmail = sNewToEmail; } else { sOldToEmail = sOldToEmail + ',' + sNewToEmail }
                        $('#' + options.targetId).textbox('setValue', sOldToEmail);
                        jQuery('#dlgExtraAccount').dialog('close');
                    }
                };
                $('#dataGridAccount').datagrid(__objInitGrid).datagrid('enableFilter');
                clsApi.request('/home/sampleDomain', function (response) { $('#dataGridAccount').datagrid('loadData', response); }, function () { }, { data: { "account": "ss4" } });
                ss4.eventEnter({
                    controlId: 'txtSearchAccount', fnCallback: function () {
                        clsApi.request('/home/sampleDomain', function (response) { $('#dataGridAccount').datagrid('loadData', response); }, function () { }, { data: { "account": $('#txtSearchAccount').val() } });
                    }
                });
            }

            jQuery('#dlgExtraAccount').dialog({ autoOpen: false, width: 800, height: 300, position: 'bottom', title: 'Tìm kiếm thông tin tài khoản CBCNV', onBeforeOpen: function () { $('#txtSearchAccount').focus(); }, onClose: function () { jQuery('#dlgExtraAccount').dialog('destroy'); } });
            jQuery('#dlgExtraAccount').dialog('open');
        };
        ss4.formatNumber = function (n, c, d, t) {
            var c = isNaN(c = Math.abs(c)) ? 2 : c,
                d = d == undefined ? "," : d,
                t = t == undefined ? "." : t,
                s = n < 0 ? "-" : "",
                i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "",
                j = (j = i.length) > 3 ? j % 3 : 0;
            return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
        };
        ss4.format_ddMMyyyy = function (date) {
            var y = date.getFullYear();
            var m = date.getMonth() + 1;
            var d = date.getDate();
            return (d < 10 ? ('0' + d) : d) + '/' + (m < 10 ? ('0' + m) : m) + '/' + y;
        };
        ss4.format_ddMMyy = function (date) {
            var y = date.getFullYear().toString().substring(2);
            var m = date.getMonth() + 1;
            var d = date.getDate();
            return (d < 10 ? ('0' + d) : d) + '/' + (m < 10 ? ('0' + m) : m) + '/' + y;
        };
        ss4.parse_ddMMyyyy = function (s) {
            if (!s) return new Date();
            var ss = (s.split('/'));
            var d = parseInt(ss[0], 10);
            var m = parseInt(ss[1], 10);
            var y = parseInt(ss[2], 10);
            if (!isNaN(y) && !isNaN(m) && !isNaN(d)) {
                return new Date(y, m - 1, d);
            } else {
                return new Date();
            }
        };
        ss4.JsonDateToddMMyyyy = function (value) {
            /*'Date(1231321313)'--> 18/03/2014*/
            if (value != null) {
                var tmp = value.substring(6, value.length - 2);
                var dt = new Date(eval(tmp));
                var y = dt.getFullYear();
                var m = dt.getMonth() + 1;
                var d = dt.getDate();
                return (d < 10 ? ('0' + d) : d) + '/' + (m < 10 ? ('0' + m) : m) + '/' + y;
            }
            return null;
        };
        ss4.cloneObject = function (obj) {
            if (obj === null || typeof obj !== 'object') {
                return obj;
            }

            var temp = obj.constructor(); // give temp the original obj's constructor
            for (var key in obj) {
                temp[key] = ss4.cloneObject(obj[key]);
            }

            return temp;
        };
        ss4.objToString = function (arrObject) { if (typeof (arrObject) != 'undefined') return $.toJSON(arrObject); return ""; };
        ss4.stringToObj = function (strVal) { return eval(strVal); };
        ss4.eventKeydown = function (arrControl) {
            if (typeof (arrControl) != 'undefined') {
                if (arrControl.isSpecial == 2) {
                    console.log(jQuery('#' + arrControl.controlId));
                    jQuery('#' + arrControl.controlId).next().bind("keyup", function (e) {
                        if (e.which == 13) {
                            e.preventDefault();
                            if (arrControl.refClass != '') {
                                jQuery('#' + arrControl.nextControlId).next().find('input').next().find('.' + arrControl.refClass).click();
                            }
                            else jQuery('#' + arrControl.nextControlId).focus();
                        }
                    });
                } else if (arrControl.isSpecial == 1) {
                    jQuery('#' + arrControl.controlId).bind("keyup", function (e) {
                        if (e.which == 13) {
                            e.preventDefault();
                            if (arrControl.refClass != '') jQuery('#' + arrControl.nextControlId).next().find('input').next().find('.' + arrControl.refClass).click();
                            else jQuery('#' + arrControl.nextControlId).focus();
                        }
                    });
                } else if (arrControl.isSpecial == 3) {
                    jQuery('#' + arrControl.controlId).keypress(function (event) {
                        var keycode = (event.keyCode ? event.keyCode : event.which);
                        if (keycode == 13) {
                            //e.preventDefault();
                            if (arrControl.refClass != '') {
                                if (arrControl.refClass == 'date-box-ss4') {
                                    jQuery('#' + arrControl.nextControlId).next().find('input')[0].focus();
                                    //jQuery('#' + arrControl.nextControlId).next().find('input').find('.' + arrControl.refClass).click();
                                }
                                else jQuery('#' + arrControl.nextControlId).next().find('input').next().find('.' + arrControl.refClass).click();
                            }
                            else jQuery('#' + arrControl.nextControlId).focus();


                            //if (arrControl.refClass != '') jQuery('#' + arrControl.nextControlId).next().find('input').next().find('.' + arrControl.refClass).click();
                            //else jQuery('#' + arrControl.nextControlId).focus();
                        }
                    });
                }
            }
        };
        ss4.eventEnter = function (newoptions) {
            var options = { controlId: '', fnCallback: null };
            options = $.extend({}, options, newoptions);
            jQuery('#' + options.controlId).bind("keyup", function (e) {
                if (e.which == 13) {
                    //e.preventDefault();
                    if (ss4.getParam(options.fnCallback))
                        options.fnCallback();
                }
            });
        };

        ss4.getRandom = function (min, max) { return Math.floor(Math.random() * (max - min + 1)) + min; }
        ss4.rhtml = function (e) {
            return "string" == typeof e && (e = e.replace(/&gt;/gi, ">"), e = e.replace(/&lt;/gi, "<"), e = e.replace(/&#039;/g, "'"), e = e.replace(/&quot;/gi, '"'), e = e.replace(/&amp;/gi, "&")), e
        }, replacechars = function (e, r, a) {
            for (var c = !0; c;) e = e.replace(r, a), -1 == e.indexOf(r) && (c = !1);
            return e;
        };
        ss4.checkSession = function () {
            var request = false;
            if (window.XMLHttpRequest) { // Mozilla/Safari
                request = new XMLHttpRequest();
            } else if (window.ActiveXObject) { // IE
                request = new ActiveXObject("Microsoft.XMLHTTP");
            }
            request.open('POST', '/clsSession', true);
            request.onreadystatechange = function () {
                if (request.readyState == 4) {
                    var session = eval('(' + request.responseText + ')');
                    if (session.valid) {
                        window.setTimeout("ss4.checkSession()", 10000);
                    } else {
                        ss4.alert({ title: 'Thông báo', message: 'Trạng thái phiên làm việc của bạn đã hết. <br>Vui lòng đăng nhập lại, cảm ơn.', fnCallback: function () { window.location.reload(); } });
                    }
                }
            }
            request.send(null);
        };

        //export
        //ss4.tableToExcel = (function () {
        //    var uri = 'data:application/vnd.ms-excel;base64,'
        //      , template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>'
        //      , base64 = function (s) { return window.btoa(unescape(encodeURIComponent(s))) }
        //      , format = function (s, c) { return s.replace(/{(\w+)}/g, function (m, p) { return c[p]; }) }
        //    return function (table, name) {
        //        if (!table.nodeType) table = document.getElementById(table)
        //        var ctx = { worksheet: name || 'Worksheet', table: table.innerHTML }
        //        window.location.href = uri + base64(format(template, ctx))
        //    }
        //})();
        ss4.tableToExcel = function (table, sheetname) {
            var uri = 'data:application/vnd.ms-excel;base64,'
              , template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--><meta http-equiv="content-type" content="text/plain; charset=UTF-8"/></head><body>{table}</body></html>'
              , base64 = function (s) { return window.btoa(unescape(encodeURIComponent(s))) }
              , format = function (s, c) { return s.replace(/{(\w+)}/g, function (m, p) { return c[p]; }) }
            if (!table.nodeType) table = document.getElementById(table)
            var ctx = { worksheet: sheetname || 'Worksheet', table: table.innerHTML }
            window.location.href = uri + base64(format(template, ctx))
        };
        ss4.tablesToSheets = function (tables, wsnames, wbname, appname) {
            arrWorksheetsXML = [];
            gColumnsLength = 0;
            gRowSpan = 0;
            wbname = typeof (wbname) == 'undefined' ? 'Workbook.xls' : wbname;
            appname = typeof (appname) == 'undefined' ? 'Excel' : appname;
            if (typeof (wsnames) == 'undefined') {
                wsnames = [];
                for (var i = 0; i < tables.length; i++) {
                    wsnames.push(tables[i]);
                }
            }

            var uri = 'data:application/vnd.ms-excel;base64,'
                , tmplWorkbookXML = '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?><Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:html="http://www.w3.org/TR/REC-html40">'
                  + '<DocumentProperties xmlns="urn:schemas-microsoft-com:office:office"><Author>Axel Richter</Author><Created>{created}</Created></DocumentProperties>'
                  + '<Styles>'
                  + '<Style ss:ID="s74"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" /><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" /><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" /><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" /></Borders> <Font ss:FontName="Times New Roman" x:Family="Roman" ss:Size="11" ss:Color="#000000" /></Style>'
	              + '<Style ss:ID="s75"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Size="11" ss:Color="#000000"/><Interior ss:Color="#F79621" ss:Pattern="Solid"/></Style>'
	              + '<Style ss:ID="s76"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Size="11" ss:Color="#000000"/><Interior ss:Color="#FCF6C9" ss:Pattern="Solid"/></Style>'
	              + '<Style ss:ID="s79"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Size="11" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#F79621" ss:Pattern="Solid"/></Style>'
	              + '<Style ss:ID="s80"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Size="11" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#FCF6C9" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s130"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#FFFFFF" ss:Bold="1"/><Interior ss:Color="#1F608F" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s131"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#EBEDA5" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s122"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#F8BC87" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s132"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#F49640" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s133"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#BDD7EE" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s134"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#89B700" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s135"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#009595" ss:Pattern="Solid"/></Style>'
                  + '<Style ss:ID="s136"><NumberFormat ss:Format="\\@"/><Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/><Borders><Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/><Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/></Borders><Font ss:FontName="Times New Roman" x:Family="Roman" ss:Color="#000000" ss:Bold="1"/><Interior ss:Color="#FF71DC" ss:Pattern="Solid"/></Style>'
	              + '<Style ss:ID="Currency"><NumberFormat ss:Format="Currency"></NumberFormat></Style>'
                  + '<Style ss:ID="Date"><NumberFormat ss:Format="Medium Date"></NumberFormat></Style>'
                  + '</Styles>'
                  + '{worksheets}</Workbook>'
                , tmplWorksheetXML = '<Worksheet ss:Name="{nameWS}"><Table>{rows}</Table></Worksheet>'
                , tmplCellXML = '<Cell{ssIndex}{attrMergeAcross}{attrMergeDown}{attributeStyleID}{attributeFormula}><Data ss:Type="{nameType}">{data}</Data></Cell>'
                , base64 = function (s) { return window.btoa(unescape(encodeURIComponent(s))) }
                , format = function (s, c) { return s.replace(/{(\w+)}/g, function (m, p) { return c[p]; }) }
            var ctx = "";
            var workbookXML = "";
            var worksheetsXML = "";
            var rowsXML = "";

            for (var i = 0; i < tables.length; i++) {
                if (!tables[i].nodeType) tables[i] = document.getElementById(tables[i]);
                var objTmp = { cols: [] };
                for (var j = 0; j < tables[i].rows.length; j++) {
                    rowsXML += '<Row>';
                    for (var k = 0; k < tables[i].rows[j].cells.length; k++) {
                        var dataType = tables[i].rows[j].cells[k].getAttribute("data-type");
                        var dataStyle = tables[i].rows[j].cells[k].getAttribute("data-style");
                        var dataValue = tables[i].rows[j].cells[k].getAttribute("data-value");
                        var dataMergeRow = tables[i].rows[j].cells[k].getAttribute("data-mergerow");
                        var dataMergeCol = tables[i].rows[j].cells[k].getAttribute("data-mergecol");
                        var dataSSIndex = tables[i].rows[j].cells[k].getAttribute("data-index");
                        var dataFormula = tables[i].rows[j].cells[k].getAttribute("data-formula");
                        dataFormula = (dataFormula) ? dataFormula : (appname == 'Calc' && dataType == 'DateTime') ? dataValue : null;

                        dataValue = (dataValue) ? dataValue : tables[i].rows[j].cells[k].innerHTML;
                        while (dataValue.indexOf('<br>') != -1 || dataValue.indexOf('<br >') != -1 || dataValue.indexOf('<br/>') != -1 || dataValue.indexOf('<br />') != -1 ||
                               dataValue.indexOf('<br style="mso-data-placement:same-cell;" />') != -1 || dataValue.indexOf('<br style="mso-data-placement:same-cell;"/>') != -1 ||
                               dataValue.indexOf('<br style="mso-data-placement:same-cell;">') != -1 || dataValue.indexOf('<br style="mso-data-placement:same-cell;" >') != -1) {
                            dataValue = dataValue.replace('<br>', '&#10;');
                            dataValue = dataValue.replace('<br >', '&#10;');
                            dataValue = dataValue.replace('<br/>', '&#10;');
                            dataValue = dataValue.replace('<br />', '&#10;');
                            dataValue = dataValue.replace('<br style="mso-data-placement:same-cell;">', '&#10;');
                            dataValue = dataValue.replace('<br style="mso-data-placement:same-cell;" >', '&#10;');
                            dataValue = dataValue.replace('<br style="mso-data-placement:same-cell;"/>', '&#10;');
                            dataValue = dataValue.replace('<br style="mso-data-placement:same-cell;" />', '&#10;');
                        }
                        //replace ky tu dac biet
                        dataValue = dataValue.replace('=""', '').replace('<', '').replace('>', '').replace('</', '');

                        ctx = {
                            attributeStyleID: dataStyle != null ? ' ss:StyleID="' + dataStyle + '"' : ' ss:StyleID="s74"',
                            attrMergeAcross: dataMergeCol != null ? ' ss:MergeAcross="' + (dataMergeCol - 1) + '"' : '',
                            attrMergeDown: dataMergeRow != null ? ' ss:MergeDown="' + (dataMergeRow - 1) + '"' : '',
                            nameType: (dataType == 'Number' || dataType == 'DateTime' || dataType == 'Boolean' || dataType == 'Error') ? dataType : 'String',
                            data: (dataFormula) ? '' : dataValue,
                            attributeFormula: (dataFormula) ? ' ss:Formula="' + dataFormula + '"' : '',
                            ssIndex: dataSSIndex != null ? ' ss:Index="' + dataSSIndex + '"' : ''
                        };
						
                        rowsXML += format(tmplCellXML, ctx);
                    }
                    rowsXML += '</Row>';
                }

                ctx = { rows: rowsXML, nameWS: wsnames[i] || 'Sheet' + i };
                worksheetsXML += format(tmplWorksheetXML, ctx);
                rowsXML = "";
            }

            ctx = { created: (new Date()).getTime(), worksheets: worksheetsXML };
            workbookXML = format(tmplWorkbookXML, ctx);

            var link = document.createElement("A");
            link.href = uri + base64(workbookXML);
            link.download = wbname || 'Workbook.xls';
            link.target = '_blank';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        };

        ss4.tableToWorld = function (tablename, fileName) {
            //required: FileSaver.js
            fileName = typeof fileName !== 'undefined' ? fileName : "jQuery-Word-Export";
            var static = {
                mhtml: {
                    top: "Mime-Version: 1.0\nContent-Base: " + location.href + "\nContent-Type: Multipart/related; boundary=\"NEXT.ITEM-BOUNDARY\";type=\"text/html\"\n\n--NEXT.ITEM-BOUNDARY\nContent-Type: text/html; charset=\"utf-8\"\nContent-Location: " + location.href + "\n\n<!DOCTYPE html>\n<html>\n_html_</html>",
                    head: "<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n<style>\n_styles_\n</style>\n</head>\n",
                    body: "<body>_body_</body>"
                }
            };

            var options = { maxWidth: 624 };
            // Clone selected element before manipulating it
            var markup = $('#' + tablename).clone();

            // Remove hidden elements from the output
            markup.each(function () {
                var self = $(this);
                if (self.is(':hidden'))
                    self.remove();
            });

            // Prepare bottom of mhtml file with image data
            var mhtmlBottom = "\n";
            mhtmlBottom += "--NEXT.ITEM-BOUNDARY--";

            //TODO: load css from included stylesheet
            var styles = "";

            // Aggregate parts of the file together 
            var fileContent = static.mhtml.top.replace("_html_", static.mhtml.head.replace("_styles_", styles) + static.mhtml.body.replace("_body_", markup.html())) + mhtmlBottom;

            // Create a Blob with the file contents
            var blob = new Blob([fileContent], { type: "application/msword;charset=utf-8" });

            saveAs(blob, fileName + ".doc");
        };
        ss4.printElement = function (el) {
            var win = window.open();
            self.focus();
            win.document.open();
            win.document.write('<' + 'html' + '><' + 'body' + '>');
            win.document.write($('#' + el).html());
            win.document.write('<' + '/body' + '><' + '/html' + '>');
            win.document.close();
            win.print();
            win.close();
        };

        //message
        ss4.sorry = function () { ss4.message({ title: 'Thông báo', message: 'Chức năng này đang xây dựng.<br>Xin lỗi vì sự bất tiện này.' }); };
        ss4.message = function (newoptions) {
            var options = { title: 'Thông báo', message: 'Thông báo tới người dùng', width: 250, height: 100, icon: 'info' };
            options = $.extend({}, options, newoptions);
            //options.title = '<span class="icon-window" style="width: 16px;height: 16px;margin-right: 5px;">&nbsp;</span>' + options.title;
            switch (options.icon) {
                case "info": options.message = '<div class="messager-icon messager-info"></div>' + options.message; break;
                case "warning": options.message = '<div class="messager-icon messager-warning"></div>' + options.message; break;
                case "question": options.message = '<div class="messager-icon messager-question"></div>' + options.message; break;
                case "error": options.message = '<div class="messager-icon messager-error"></div>' + options.message; break;
                default: options.message = '<div class="messager-icon messager-info"></div>' + options.message; break;
            }
            $.messager.show({
                title: options.title, timeout: 1000, msg: options.message, showType: 'show', icon: 'info', width: options.width, height: options.height, modal: true,
                style: {
                    right: '',
                    bottom: ''
                }
            });
        };
        ss4.alert = function (newoptions) {
            var options = { title: 'Thông báo', message: 'Thông báo tới người dùng', width: 300, height: 150, icon: 'info' };
            options = jQuery.extend({}, options, newoptions);
            options.title = '<span class="icon-window" style="width: 16px;height: 16px;margin-right: 5px;">&nbsp;</span>' + options.title;
            if (ss4.getParam(options.fnCallback)) jQuery.messager.alert({ title: options.title, msg: options.message, fn: options.fnCallback, width: options.width, height: options.height });
            else jQuery.messager.alert({ title: options.title, msg: options.message, icon: 'info', width: options.width, height: options.height, icon: options.icon });
        };
        ss4.confirm = function (newoptions) {
            var options = { title: 'Confirm', message: 'Are you sure, you want to delete this record?', width: 350, height: 150, fnCallback: null };
            options = $.extend({}, options, newoptions);
            options.title = '<span class="icon-window" style="width: 16px;height: 16px;margin-right: 5px;">&nbsp;</span>' + options.title;
            //$.messager.confirm(options.title, options.message, function (r) { if (r) options.fnCallback(); });
            $.messager.confirm({ title: options.title, msg: options.message, width: options.width, height: options.height, fn: function (r) { if (r) options.fnCallback(); } });
        };
        ss4.shwProgress = function (bShow, newoptions) {
            var options = { title: 'Đợi trong giây lát', msg: 'Đang gửi...', interval: 3000 };
            options = $.extend({}, options, newoptions);
            if (bShow) $.messager.progress({ title: options.title, msg: options.msg, interval: options.interval });
            else $.messager.progress('close');
        };

        //dialog
        ss4.openDialog = function (newoptions) {
            var options = { dialogId: '', title: '<i class="fa fa-desktop"></i> Tiêu đề <i class="fa fa-angle-right"></i> Hiệu chỉnh', url: '', method: 'GET', data: null, width: 600, height: 400, maximizable: false, closable: false };
            options = $.extend({}, options, newoptions);
            //console.log(options);

            //check exists id of dialog
            if ($('#dlgModelSub_' + options.dialogId).length != 0) {
                $('#dlgModelSub_' + options.dialogId).remove();
                //$('#dlgModelSub_' + options.dialogId).html('');
                $('#dlgModelSub_' + options.dialogId).window('destroy');
            }
                //$('body').append('<div id="dlgModelSub_' + options.dialogId + '" class="easyui-window" data-options="modal: true,closed: true,href: \'/\',method: \'post\'," title="<i class=\'fa fa-desktop\'></i>" style="width:400px;height:300px;padding:10px;"></div>');
            //else { $('#dlgModelSub_' + options.dialogId).window('destroy'); }
            $('body').append('<div id="dlgModelSub_' + options.dialogId + '" class="extjsui-window" data-options="modal: true,closed: false,href: \'/\',method: \'post\'," title="<i class=\'fa fa-desktop\'></i>" style="width:400px;height:300px;padding:0px;"></div>');

            $('#dlgModelSub_' + options.dialogId).window({
                title: options.title,
                href: options.url,
                method: options.method,
                queryParams: options.data,
                width: options.width,
                height: options.height,
                collapsible: false,
                minimizable: false,
                maximizable: options.maximizable,
                closable: options.closable,
                closed: false,
                modal: true,
                position: 'center',
                loadingMessage: 'Vui lòng đợi',
                footer: '#' + options.buttons
            });
            //$('#dlgModelSub_' + options.dialogId).window('open');
        };
        ss4.closeDialog = function (dialogId) { $('#dlgModelSub_' + dialogId).dialog('close'); };
        ss4.closeWindow = function (dialogId) { $('#dlgModelSub_' + dialogId).window('close'); };
        ss4.frameDialog = function (newoptions) {
            var options = { dialogId: '', title: '', url: '', width: 600, height: 400 };
            options = $.extend({}, options, newoptions);
            if (options.url == '') { ss4.message({ title: 'ERR', message: 'Đường dẫn không thể là rỗng!' }); return false; }

            if ($('#IFrame_' + options.dialogId).length != 0)
                $('#IFrame_' + options.dialogId).remove();
            $('body').append('<div id="IFrame_' + options.dialogId + '" class="extjsui-dialog" title="&nbsp;' + options.title + '" style="width:' + options.width + 'px;height:' + options.height + 'px;" data-options="iconCls:\'icon-print\',resizable:false,maximizable:true,modal:true"><iframe src="' + options.url + '" width="100%" height="98%" /></div>');

            $('#IFrame_' + options.dialogId).dialog();
        };
        ss4.frameDialog1 = function (newoptions) {
            var options = { dialogId: '', title: '', url: '', width: 600, height: 400 };
            options = $.extend({}, options, newoptions);
            if (options.url == '') { ss4.message({ title: 'ERR', message: 'Đường dẫn không thể là rỗng!' }); return false; }

            if ($('#IFrame_' + options.dialogId).length != 0)
                $('#IFrame_' + options.dialogId).remove();
            $('body').append('<div id="IFrame_' + options.dialogId + '" class="extjsui-dialog" style="width:' + options.width + 'px;height:' + options.height + 'px;" data-options="resizable:false,modal:true"><iframe id="iframe_' + options.dialogId + '" src="' + options.url + '" width="100%" height="99%" /></div>');

            $('#IFrame_' + options.dialogId).dialog({
                title: options.title,
                width: options.width,
                height: options.height,
            });

            //show dialogProgress
            ss4.Loading(true);
            $('iframe#iframe_' + options.dialogId).load(function () {
                ss4.Loading(false);
            });
        };

        ss4.closeWaiting = function (newoptions) {
            var options = { dialogId: '' };
            options = $.extend({}, options, newoptions);
            $('#IFrame_' + options.dialogId).dialog('close');
        };
        ss4.shwWaiting = function (newoptions) {
            var options = { dialogId: '', title: 'Đang xử lý dữ liệu', width: 300, height: 122 };
            options = $.extend({}, options, newoptions);

            if ($('#IFrame_' + options.dialogId).length != 0) {
                $('#IFrame_' + options.dialogId).dialog('close');
                $('#IFrame_' + options.dialogId).remove();
            }
            $('body').append('<div id="IFrame_' + options.dialogId + '" class="extjsui-dialog" title="&nbsp;' + options.title + '" style="width:' + options.width + 'px;height:' + options.height + 'px;padding:10px;text-align:center;" data-options="iconCls:\'icon-reload\',resizable:false,modal:true">' +
                '<span>Vui lòng đợi....</span>' +
                '<div id="IFrame_' + options.dialogId + '_progress' + '" class="extjsui-progressbar" style="width:270px;"></div>' +
                '</div>');

            function startProgress() {
                var value = $('#IFrame_' + options.dialogId + '_progress').progressbar('getValue');
                if (value < 100) {
                    value += Math.floor(Math.random() * 10);
                    $('#IFrame_' + options.dialogId + '_progress').progressbar('setValue', value);
                    setTimeout(arguments.callee, 200);
                    if (value > 100) $('#IFrame_' + options.dialogId + '_progress').progressbar('setValue', 0);
                }
            };

            $('#IFrame_' + options.dialogId).dialog({
                closable: false,
                onBeforeOpen: function () {
                    $('#IFrame_' + options.dialogId + '_progress').progressbar();
                    startProgress();
                }
            });
        };

        ss4.RowMix = function (eleSelect) {
            var tenSp = $($(eleSelect + ":first-child").get(0)).find('div').text();
            var count = 0;
            var ele = $($(eleSelect + ":first-child").get(0));
            $(eleSelect).each(function () {
                if ($(this).find('div').text() != tenSp && $(this).find('div').text() != "") {
                    ele.attr("rowspan", count);
                    //ele.html('vertical-align', 'middle !important');
                    count = 1;
                    tenSp = $(this).find('div').text();
                    ele = $(this);
                } else if ($(this).find('div').text() == tenSp && $(this).find('div').text() != "") {
                    count++;
                    if (count > 1) $(this).remove();
                }
            });
            ele.attr("rowspan", count);
            //ele.css('vertical-align', 'middle !important');
        };

        var settings = { 'datagrid': {}, 'table': {}, 'data': {} };
        ss4.settings = settings;
        //datagrid extjs
        ss4.settings.datagrid.setup = function (gridId, options) { jQuery('#' + gridId).datagrid(options); };
        ss4.settings.datagrid.allowRowFilter = function (gridId) { jQuery('#' + gridId).datagrid('enableFilter'); };
        ss4.settings.datagrid.allowMoveColumn = function (gridId) { jQuery('#' + gridId).datagrid('columnMoving'); };
        ss4.settings.datagrid.loading = function (gridId) {
            //$("#dtgSearch").datagrid('loading');//hiển thị loading
            //$("#dtgSearch").datagrid('loaded'); //ẩn loading trên grid
            //jQuery('#' + gridId).datagrid({
            //    onBeforeLoad: function () { ss4.Loading(true); },
            //    onLoadError: function () { ss4.Loading(false); },
            //    onLoadSuccess: function () { ss4.Loading(false); }
            //});            
        };
        ss4.settings.datagrid.clear = function (gridId) { $('#' + gridId).datagrid('loadData', { "total": 0, "rows": [] }); };

        //table
        ss4.settings.table.setup = function (newoptions) {
            //require: jquery.handsontable.min.js
            var options = { divId: 'divTable', data: [], minSpareRows: 0, autoWrapRow: true, colWidths: [150, 620], colHeaders: [], contextMenu: false, removeRowPlugin: false, scrollH: 'auto', columns: [] };
            options = $.extend({}, options, newoptions);

            jQuery("#" + options.divId).handsontable({
                data: options.data,
                minSpareRows: options.minSpareRows,
                autoWrapRow: options.autoWrapRow,
                //colWidths: eval(hstblReCalcWidthCol([300, 600],939,'TitleRuler')),            
                colWidths: options.colWidths,
                colHeaders: options.colHeaders,
                contextMenu: options.contextMenu,
                removeRowPlugin: options.removeRowPlugin,
                scrollH: options.scrollH,
                columns: options.columns
            });
        };
        ss4.settings.table.getData = function (divTable) {
            return jQuery("#" + divTable).data('handsontable').getData();
        };


        //excute start
        $('body').bind('click', function () {
            if ($('#mnuHosochuaduyet').css('display') == "block") showhide('mnuHosochuaduyet');
        });
        
    })(jQuery);

    var clsApi = new ss4.clsApi();
    ss4.checkSession();

	
	
	
//script for autocomplete
//desc: 
// gôm dữ liệu ul li a#href => thành 1 array link | 1 array text
// bind vào input#autocomplete
// trong textbox: có thể nhập có dấu or không dấu luôn :)
// txtquicklink: <input type="text" id="txtquicklink" placeholder="Tìm chức năng (Enter)" style="width: 100%;padding:8px 0px;">

    var slideNames = [], slideLinks = [];
    $('.sidebar-menu a').each(function (i, v) {
        slideLinks.push($(this).attr('href'));
        slideNames.push($(this).text().trim());
    });

    var names = ["Jörn Zaefferer", "Scott González", "John Resig"];    
    var accentMap = {
        "á": "a", "à": "a", "ả": "a", "ã": "a", "ạ": "a",
        "ắ": "a", "ằ": "a", "ẳ": "a", "ẵ": "a", "ặ": "a",
        "ấ": "a", "ầ": "a", "ẩ": "a", "ẫ": "a", "ậ": "a",
        "ó": "o", "ò": "o", "ỏ": "o", "õ": "o", "ọ": "o",
        "ô": "o", "ố": "o", "ồ": "o", "ổ": "o", "ỗ": "o", "ộ": "o",
        "ơ": "o", "ớ": "o", "ờ": "o", "ở": "o", "ỡ": "o", "ợ": "o",
        "é": "e", "è": "e", "ẻ": "e", "ẽ": "e", "ẹ": "e",
        "ê": "e", "ế": "e", "ề": "e", "ể": "e", "ễ": "e", "ệ": "e",
        "í": "i", "ì": "i", "ỉ": "i", "ĩ": "i", "ị": "i",
        "ý": "y", "ỳ": "y", "ỷ": "y", "ỹ": "y", "ỵ": "y",
        "đ": "d", "Đ": "d",
    };
    var normalize = function (term) {
        var ret = "";
        for (var i = 0; i < term.length; i++) {
            ret += accentMap[term.charAt(i)] || term.charAt(i);
        }
        return ret;
    };
    $("#txtquicklink").autocomplete({
        source: function (request, response) {
            var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");
            response($.grep(slideNames, function (value) {
                value = value.label || value.value || value;
                return matcher.test(value) || matcher.test(normalize(value));
            }));
        }
    });
    $('#txtquicklink').bind('keydown', function (e) {
        if (e.keyCode == 13) {
            var sResult = $(this).val();
            if (sResult != '') {
                var searchIndex = slideNames.indexOf(sResult);
                if (searchIndex >= 0 && (slideLinks[searchIndex] != 'javascript:;' || slideLinks[searchIndex] != 'javascript:void(0);' || slideLinks[searchIndex] != '#')) {
                    window.location = location.origin + slideLinks[searchIndex];
                }
            }
            return false;
        }
    });
//end script for autocomplete