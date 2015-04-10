jQuery(document).ready(function() {
    var http = jQuery.ajax('data/datasets.json');
    http.success(function(data) {
        var datasets = data.datasets;
        var categories = data.categories;

        var source    = jQuery('#item-template').html();
        var template  = Handlebars.compile(source);
        var container = jQuery('.featured-datasets .wrapper');

        for (var key in categories) {
            var subsets = categories[key].map(function(title_id) {
                return datasets[title_id];
            });
            var data = {category:key, datasets:subsets};
            var rendered = template(data);

            container.append(rendered);
        };
    });
})
