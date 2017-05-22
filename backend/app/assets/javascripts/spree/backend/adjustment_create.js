Spree.AdjustmentCreateView = Backbone.View.extend({
  events: {
    "change .js-adjustable": "render",
  },

  initialize: function() {
    this.render();
  },

  render: function() {
    var selected = this.$('.js-adjustable option:selected').data('adjustable-type')
    $('.js-adjustable-type').val(selected);
  }
})

$(function() {
  $('.js-adjustable-fields').each(function() {
    new Spree.AdjustmentCreateView({
      el: this
    });
  });
});
