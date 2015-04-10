jQuery(document).ready(function() {
    var http = jQuery.ajax('data/datasets.json');
    http.success(function(data) {
        var datasets = data.datasets;
        var categories = datasets.reduce(
            function(hash, ds) {
                var cat = ds.category;
                if (undefined === hash[cat]) {
                    hash[cat] = [];
                }
                hash[cat].push(ds);

                return hash;
            },
            {}
        );
        var sorted_cats = (function(hash) {
            var arry = [];
            for (var key in hash) { arry.push(key) }
            return arry.sort();
        })(categories);

        var source    = jQuery('#item-template').html();
        var template  = Handlebars.compile(source);
        var container = jQuery('.featured-datasets .wrapper');

        sorted_cats.map(function(key) {
            var subsets = categories[key];
            var data = {category:key, datasets:subsets};
            var rendered = template(data);

            container.append(rendered);
        });
    });
})
