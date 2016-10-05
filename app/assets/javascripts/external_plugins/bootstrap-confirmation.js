
/* ===========================================================
 * bootstrap-tooltip.js v2.3.2
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

    "use strict"; // jshint ;_;


    /* TOOLTIP PUBLIC CLASS DEFINITION
     * =============================== */

    var Tooltip = function (element, options) {
        this.init('tooltip', element, options)
    }

    Tooltip.prototype = {

        constructor: Tooltip

        , init: function (type, element, options) {
            var eventIn
                , eventOut
                , triggers
                , trigger
                , i

            this.type = type
            this.$element = $(element)
            this.options = this.getOptions(options)
            this.enabled = true

            triggers = this.options.trigger.split(' ')

            for (i = triggers.length; i--;) {
                trigger = triggers[i]
                if (trigger == 'click') {
                    this.$element.on('click.' + this.type, this.options.selector, $.proxy(this.toggle, this))
                } else if (trigger != 'manual') {
                    eventIn = trigger == 'hover' ? 'mouseenter' : 'focus'
                    eventOut = trigger == 'hover' ? 'mouseleave' : 'blur'
                    this.$element.on(eventIn + '.' + this.type, this.options.selector, $.proxy(this.enter, this))
                    this.$element.on(eventOut + '.' + this.type, this.options.selector, $.proxy(this.leave, this))
                }
            }

            this.options.selector ?
                (this._options = $.extend({}, this.options, { trigger: 'manual', selector: '' })) :
                this.fixTitle()
        }

        , getOptions: function (options) {
            options = $.extend({}, $.fn[this.type].defaults, this.$element.data(), options)

            if (options.delay && typeof options.delay == 'number') {
                options.delay = {
                    show: options.delay
                    , hide: options.delay
                }
            }

            return options
        }

        , enter: function (e) {
            var defaults = $.fn[this.type].defaults
                , options = {}
                , self

            this._options && $.each(this._options, function (key, value) {
                if (defaults[key] != value) options[key] = value
            }, this)

            self = $(e.currentTarget)[this.type](options).data(this.type)

            if (!self.options.delay || !self.options.delay.show) return self.show()

            clearTimeout(this.timeout)
            self.hoverState = 'in'
            this.timeout = setTimeout(function() {
                if (self.hoverState == 'in') self.show()
            }, self.options.delay.show)
        }

        , leave: function (e) {
            var self = $(e.currentTarget)[this.type](this._options).data(this.type)

            if (this.timeout) clearTimeout(this.timeout)
            if (!self.options.delay || !self.options.delay.hide) return self.hide()

            self.hoverState = 'out'
            this.timeout = setTimeout(function() {
                if (self.hoverState == 'out') self.hide()
            }, self.options.delay.hide)
        }

        , show: function () {
            var $tip
                , pos
                , actualWidth
                , actualHeight
                , placement
                , tp
                , e = $.Event('show')

            if (this.hasContent() && this.enabled) {
                this.$element.trigger(e)
                if (e.isDefaultPrevented()) return
                $tip = this.tip()
                this.setContent()

                if (this.options.animation) {
                    $tip.addClass('fade')
                }

                placement = typeof this.options.placement == 'function' ?
                    this.options.placement.call(this, $tip[0], this.$element[0]) :
                    this.options.placement

                $tip
                    .detach()
                    .css({ top: 0, left: 0, display: 'block' })

                this.options.container ? $tip.appendTo(this.options.container) : $tip.insertAfter(this.$element)

                pos = this.getPosition()

                actualWidth = $tip[0].offsetWidth
                actualHeight = $tip[0].offsetHeight

                switch (placement) {
                    case 'bottom':
                        tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
                        break
                    case 'top':
                        tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
                        break
                    case 'left':
                        tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
                        break
                    case 'right':
                        tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}
                        break
                }

                this.applyPlacement(tp, placement)
                this.$element.trigger('shown')
            }
        }

        , applyPlacement: function(offset, placement){
            var $tip = this.tip()
                , width = $tip[0].offsetWidth
                , height = $tip[0].offsetHeight
                , actualWidth
                , actualHeight
                , delta
                , replace

            $tip
                .offset(offset)
                .addClass(placement)
                .addClass('in')

            actualWidth = $tip[0].offsetWidth
            actualHeight = $tip[0].offsetHeight

            if (placement == 'top' && actualHeight != height) {
                offset.top = offset.top + height - actualHeight
                replace = true
            }

            if (placement == 'bottom' || placement == 'top') {
                delta = 0

                if (offset.left < 0){
                    delta = offset.left * -2
                    offset.left = 0
                    $tip.offset(offset)
                    actualWidth = $tip[0].offsetWidth
                    actualHeight = $tip[0].offsetHeight
                }

                this.replaceArrow(delta - width + actualWidth, actualWidth, 'left')
            } else {
                this.replaceArrow(actualHeight - height, actualHeight, 'top')
            }

            if (replace) $tip.offset(offset)
        }

        , replaceArrow: function(delta, dimension, position){
            this
                .arrow()
                .css(position, delta ? (50 * (1 - delta / dimension) + "%") : '')
        }

        , setContent: function () {
            var $tip = this.tip()
                , title = this.getTitle()

            $tip.find('.tooltip-inner')[this.options.html ? 'html' : 'text'](title)
            $tip.removeClass('fade in top bottom left right')
        }

        , hide: function () {
            var that = this
                , $tip = this.tip()
                , e = $.Event('hide')

            this.$element.trigger(e)
            if (e.isDefaultPrevented()) return

            $tip.removeClass('in')

            function removeWithAnimation() {
                var timeout = setTimeout(function () {
                    $tip.off($.support.transition.end).detach()
                }, 500)

                $tip.one($.support.transition.end, function () {
                    clearTimeout(timeout)
                    $tip.detach()
                })
            }

            $.support.transition && this.$tip.hasClass('fade') ?
                removeWithAnimation() :
                $tip.detach()

            this.$element.trigger('hidden')

            return this
        }

        , fixTitle: function () {
            var $e = this.$element
            if ($e.attr('title') || typeof($e.attr('data-original-title')) != 'string') {
                $e.attr('data-original-title', $e.attr('title') || '').attr('title', '')
            }
        }

        , hasContent: function () {
            return this.getTitle()
        }

        , getPosition: function () {
            var el = this.$element[0]
            return $.extend({}, (typeof el.getBoundingClientRect == 'function') ? el.getBoundingClientRect() : {
                width: el.offsetWidth
                , height: el.offsetHeight
            }, this.$element.offset())
        }

        , getTitle: function () {
            var title
                , $e = this.$element
                , o = this.options

            title = $e.attr('data-original-title')
            || (typeof o.title == 'function' ? o.title.call($e[0]) :  o.title)

            return title
        }

        , tip: function () {
            return this.$tip = this.$tip || $(this.options.template)
        }

        , arrow: function(){
            return this.$arrow = this.$arrow || this.tip().find(".tooltip-arrow")
        }

        , validate: function () {
            if (!this.$element[0].parentNode) {
                this.hide()
                this.$element = null
                this.options = null
            }
        }

        , enable: function () {
            this.enabled = true
        }

        , disable: function () {
            this.enabled = false
        }

        , toggleEnabled: function () {
            this.enabled = !this.enabled
        }

        , toggle: function (e) {
            var self = e ? $(e.currentTarget)[this.type](this._options).data(this.type) : this
            self.tip().hasClass('in') ? self.hide() : self.show()
        }

        , destroy: function () {
            this.hide().$element.off('.' + this.type).removeData(this.type)
        }

    }


    /* TOOLTIP PLUGIN DEFINITION
     * ========================= */

    var old = $.fn.tooltip2

    $.fn.tooltip2 = function ( option ) {
        return this.each(function () {
            var $this = $(this)
                , data = $this.data('tooltip')
                , options = typeof option == 'object' && option
            if (!data) $this.data('tooltip', (data = new Tooltip(this, options)))
            if (typeof option == 'string') data[option]()
        })
    }

    $.fn.tooltip2.Constructor = Tooltip

    $.fn.tooltip2.defaults = {
        animation: true
        , placement: 'top'
        , selector: false
        , template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
        , trigger: 'hover focus'
        , title: ''
        , delay: 0
        , html: false
        , container: false
    }


    /* TOOLTIP NO CONFLICT
     * =================== */

    $.fn.tooltip2.noConflict = function () {
        $.fn.tooltip2 = old
        return this
    }

}(window.jQuery);


/* ===========================================================
 * bootstrap-confirmation.js v1.0.1
 * http://ethaizone.github.io/Bootstrap-Confirmation/
 * ===========================================================
 * Copyright 2013 Nimit Suwannagate <ethaizone@hotmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================================================== */


!function ($) {

    "use strict"; // jshint ;_;


    /* CONFIRMATION PUBLIC CLASS DEFINITION
     * =============================== */

    //var for check event at body can have only one.
    var event_body = false;

    var Confirmation = function (element, options) {
        var that = this;

        // remove href attribute of button
        $(element).removeAttr('href')

        this.init('confirmation', element, options)

        $(element).on('show', function(e) {
            var options = that.options;
            var all = options.all_selector;
            if(options.singleton) {
                $(all).not(that.$element).confirmation('hide');
            }
        });

        $(element).on('shown', function(e) {
            var options = that.options;
            var all = options.all_selector;
            $(this).next('.popover').one('click.dismiss.confirmation', '[data-dismiss="confirmation"]', $.proxy(that.hide, that))
            if(that.isPopout()) {
                if(!event_body) {
                    event_body = $('body').on('click', function (e) {
                        if($(all).is(e.target)) return;
                        if($(all).has(e.target).length) return;
                        if($(all).next('div').has(e.target).length) return;

                        $(all).confirmation('hide');
                        $('body').unbind(e);
                        event_body = false;

                        return;
                    });
                }
            }
        });
    }


    /* NOTE: CONFIRMATION EXTENDS BOOTSTRAP-TOOLTIP.js
     ========================================== */

    Confirmation.prototype = $.extend({}, $.fn.tooltip2.Constructor.prototype, {

        constructor: Confirmation

        , setContent: function () {
            var $tip = this.tip()
                , $btnOk = this.btnOk()
                , $btnCancel = this.btnCancel()
                , title = this.getTitle()
                , href = this.getHref()
                , target = this.getTarget()
                , $e = this.$element
                , btnOkClass = this.getBtnOkClass()
                , btnCancelClass = this.getBtnCancelClass()
                , btnOkLabel = this.getBtnOkLabel()
                , btnCancelLabel = this.getBtnCancelLabel()
                , o = this.options

            $tip.find('.popover-title').text(title)

            $btnOk.addClass(btnOkClass).html(btnOkLabel).attr('href', href).attr('target', target).on('click', o.onConfirm)
            $btnCancel.addClass(btnCancelClass).html(btnCancelLabel).on('click', o.onCancel)

            $tip.removeClass('fade top bottom left right in')
        }

        , hasContent: function () {
            return this.getTitle()
        }

        , isPopout: function () {
            var popout
                , $e = this.$element
                , o = this.options

            popout = $e.attr('data-popout') || (typeof o.popout == 'function' ? o.popout.call($e[0]) :	o.popout)

            if(popout == 'false') popout = false;

            return popout
        }


        , getHref: function () {
            var href
                , $e = this.$element
                , o = this.options

            href = $e.attr('data-href') || (typeof o.href == 'function' ? o.href.call($e[0]) :	o.href)

            return href
        }

        , getTarget: function () {
            var target
                , $e = this.$element
                , o = this.options

            target = $e.attr('data-target') || (typeof o.target == 'function' ? o.target.call($e[0]) :	o.target)

            return target
        }

        , getBtnOkClass: function () {
            var btnOkClass
                , $e = this.$element
                , o = this.options

            btnOkClass = $e.attr('data-btnOkClass') || (typeof o.btnOkClass == 'function' ? o.btnOkClass.call($e[0]) :	o.btnOkClass)

            return btnOkClass
        }

        , getBtnCancelClass: function () {
            var btnCancelClass
                , $e = this.$element
                , o = this.options

            btnCancelClass = $e.attr('data-btnCancelClass') || (typeof o.btnCancelClass == 'function' ? o.btnCancelClass.call($e[0]) :	o.btnCancelClass)

            return btnCancelClass
        }

        , getBtnOkLabel: function () {
            var btnOkLabel
                , $e = this.$element
                , o = this.options

            btnOkLabel = $e.attr('data-btnOkLabel') || (typeof o.btnOkLabel == 'function' ? o.btnOkLabel.call($e[0]) :	o.btnOkLabel)

            return btnOkLabel
        }

        , getBtnCancelLabel: function () {
            var btnCancelLabel
                , $e = this.$element
                , o = this.options

            btnCancelLabel = $e.attr('data-btnCancelLabel') || (typeof o.btnCancelLabel == 'function' ? o.btnCancelLabel.call($e[0]) :	o.btnCancelLabel)

            return btnCancelLabel
        }

        , tip: function () {
            this.$tip = this.$tip || $(this.options.template)
            return this.$tip
        }

        , btnOk: function () {
            var $tip = this.tip()
            return $tip.find('.popover-content > div > a:not([data-dismiss="confirmation"])')
        }

        , btnCancel: function () {
            var $tip = this.tip()
            return $tip.find('.popover-content > div > a[data-dismiss="confirmation"]')
        }

        , hide: function () {
            var $btnOk = this.btnOk()
                , $btnCancel = this.btnCancel()

            //$.fn.tooltip.Constructor.prototype.hide.call(this)
            $.fn.tooltip2.Constructor.prototype.hide.call(this)

            $btnOk.off('click')
            $btnCancel.off('click')

            return this
        }

        , destroy: function () {
            this.hide().$element.off('.' + this.type).removeData(this.type)
        }

        , setOptions: function (newOptions) {
            this.options = $.extend({}, this.options, newOptions || {});
        }

    })


    /* CONFIRMATION PLUGIN DEFINITION
     * ======================= */

    var old = $.fn.confirmation

    $.fn.confirmation = function (option, param) {
        var that = this
        return this.each(function () {
            var $this = $(this)
                , data = $this.data('confirmation')
                , options = typeof option == 'object' && option
            options = options || {}
            options.all_selector = that.selector
            if (!data) $this.data('confirmation', (data = new Confirmation(this, options)))
            if (typeof option == 'string') {
                if (option === 'option') {
                    data.setOptions(param)
                } else {
                    data[option]();
                }
            }
        })
    }

    $.fn.confirmation.Constructor = Confirmation

    $.fn.confirmation.defaults = $.extend({} , $.fn.tooltip2.defaults, {
        placement: 'top'
        , trigger: 'click'
        , target : '_self'
        , href   : '#'
        , title: 'Are you sure?'
        , template: '<div class="popover">' +
        '<div class="arrow"></div>' +
        '<h3 class="popover-title"></h3>' +
        '<div class="popover-content text-center">' +
        '<div class="btn-group">' +
        '<a class="btn btn-small" href="" target=""></a>' +
        '<a class="btn btn-small btn-danger" data-dismiss="confirmation"></a>' +
        '</div>' +
        '</div>' +
        '</div>'
        , btnOkClass:  'btn-primary'
        , btnCancelClass:  ''
        , btnOkLabel: '<i class="icon-ok-sign icon-white"></i> Yes'
        , btnCancelLabel: '<i class="icon-remove-sign"></i> No'
        , singleton: false
        , popout: false
        , onConfirm: function(){}
        , onCancel: function(){}
    })


    /* POPOVER NO CONFLICT
     * =================== */

    $.fn.confirmation.noConflict = function () {
        $.fn.confirmation = old
        return this
    }

}(window.jQuery);