/*!
 *nicelabel JQuery Plugin
 *
 *@file: jquery-nicelabel.js version 1.0
 *@author: PJY
 *@date: 2016/05/15
 *@site: http://www.cat666.com/
 *@license: MIT License
 */
 
;(function( $ ){
	
	$.fn.nicelabel = function(options) {
		
		var settings = $.extend({},{
			
			//默认配置
			
			uselabel: true,				//如果是文本按钮,默认使用图标
			
			checked_text: 'Checked',	//如果是文本按钮,默认选定文本
			
			unchecked_text: 'Unchecked',	//如果是文本按钮,默认未选定文本
			
			checked_ico: './nicelabel/ico/tick-checked.png', 	//如果是文本按钮,默认选定图标
			
			unchecked_ico: './nicelabel/ico/tick-unchecked.png', 	//如果是文本按钮,默认未选定图标
			
		},options);		
		
		return this.each(function(){
			
			var obj = $(this),
				label_opts = toJSON($(this).attr('data-nicelabel') || '{}'), 	//将字符串转化为对象
				
				position_class,
				
				checked_ico,
				
				unchecked_ico,
				
				input_id;
				
			if( label_opts.position_class ) {
				
				position_class = label_opts.position_class;
				
			}else {
				
				position_class = 'nicelabel-default-position';
				
			}	
			
			if( label_opts.checked_text ) {
				
				checked_text = label_opts.checked_text;
				
			}else {
				
				checked_text = settings.checked_text;
				
			}	
			
			if( label_opts.unchecked_text ) {
				
				unchecked_text = label_opts.unchecked_text;
				
			}else {
				
				unchecked_text = settings.unchecked_text;
				
			}
			
			//如果不是单选或复选框,返回
			if( obj.is( ":checkbox" ) === false && obj.is( ":radio" ) === false ){
				
				return this;
				
			}
			//如果没有id,动态添加id
			input_id = obj.attr( "id" );
			
			if(input_id == null) {
				
				var input_id_number = Math.ceil( Math.random() * 1024000 );
				
				input_id = "nicelabel-" + input_id_number;
				
				while( $( "#" + input_id ).length !== 0 )
				{
					input_id_number++;
					
					input_id = "nicelabel-" + input_id_number;
					
				}
				obj.attr('id', input_id );
			}
			
			if(obj.attr("class") == "circle-nicelabel") {
				
				obj.after( create( input_id, 'circle', position_class ) );
				
			}else if(obj.attr("class") == "rect-nicelabel") {
				
				obj.after( create( input_id, 'rect', position_class ) );
				
			}else if(obj.attr("class") == "text-nicelabel"){
				
				obj.after( create( input_id, 'text', position_class, settings.uselabel, checked_text, unchecked_text, settings.checked_ico, settings.unchecked_ico) );
				
			}
			
			
		});
		
	}
	
	var create = function( input_id, label_theme ,position_class, uselabel, checked_text, unchecked_text, checked_ico, unchecked_ico) {
	
		var label_html;
		
		if(label_theme == 'circle') {
			
			label_html = '<label class="' + position_class + '" for="' + input_id + '">' +
							'<div class="circle-btn"></div>' +
						'</label>';
						
		}else if(label_theme == 'rect') {
			
			label_html = '<label class="' + position_class + '" for="' + input_id + '">' +
							'<div class="rect-btn"></div>' +
						'</label>';
			
		}else if(label_theme == 'text') {
			if( uselabel == true ) {
				
				label_html = '<label class="' + position_class + '" for="' + input_id + '">' +
								'<span class="nicelabel-unchecked-image" style="background-image: url( '+ unchecked_ico +' );"></span>' +
								'<span class="nicelabel-unchecked">'+ unchecked_text +'</span>' +
								'<span class="nicelabel-checked-image" style="background-image: url( '+ checked_ico +' );"></span>' +
								'<span class="nicelabel-checked">'+ checked_text +'</span>' +
							'</label>';
							
			}else {
				
				label_html = '<label class="' + position_class + '" for="' + input_id + '">' +
								'<span class="nicelabel-unchecked">'+ unchecked_text +'</span>' +
								'<span class="nicelabel-checked">'+ checked_text +'</span>' +
							'</label>';
							
			}

			
		}
		return label_html;
	};
	/**
	 * Javascript JSON implementation
	 * (Parse Method Only)
	 * https://github.com/douglascrockford/JSON-js/blob/master/json2.js
	 * Only using for parse method when parsing data-setup attribute JSON.
	 * @suppress {undefinedVars}
	 * @namespace
	 * @private
	 */
	var cx = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;

	var toJSON = function (text, reviver) {
		var j;

		function walk(holder, key) {
			var k, v, value = holder[key];
			if (value && typeof value === 'object') {
				for (k in value) {
					if (Object.prototype.hasOwnProperty.call(value, k)) {
						v = walk(value, k);
						if (v !== undefined) {
							value[k] = v;
						} else {
							delete value[k];
						}
					}
				}
			}
			return reviver.call(holder, key, value);
		}
		text = String(text);
		cx.lastIndex = 0;
		if (cx.test(text)) {
			text = text.replace(cx, function (a) {
				return '\\u' +
					('0000' + a.charCodeAt(0).toString(16)).slice(-4);
			});
		}

		if (/^[\],:{}\s]*$/
				.test(text.replace(/\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
					.replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
					.replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {

			j = eval('(' + text + ')');

			return typeof reviver === 'function' ?
				  walk({'': j}, '') : j;
		}

		throw new SyntaxError('JSON.parse(): invalid or malformed JSON data');
	};
	
}( jQuery ));
