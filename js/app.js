jQuery(document).ready(function() {
    // form.onsubmit that disables submission - thus allowing handling
    // of search query in JavaScript
    //
    var disableSubmit = function(formId) {
        var form = document.getElementById('search_form');
        form.onsubmit = function(evt) { return false; };
    }

    // load all datasets into index.html from JSON
    //
    var initializeDatasets = function () {
        var http = jQuery.ajax('data/datasets.json');
        http.success(function(data) {
            var datasets = data.datasets;
            var categories = data.categories;
            var indexSource = data.index_source;

            var source    = jQuery('#item-template').html();
            var template  = Handlebars.compile(source);
            var container = jQuery('.featured-datasets .wrapper');

            var loadCategories = function(categories) {
                var subsets, dataToRender, rendered;

                for (var key in categories) {
                    subsets = categories[key].map(function(title_id) {
                        return datasets[title_id];
                    });
                    dataToRender = {category:key, datasets:subsets};
                    rendered = template(dataToRender);

                    container.append(rendered);
                };
            }

            // set up in-memory search
            disableSubmit('search_form');
            loadCategories(categories);
            initializeSearch(data.index_source, container, template);

            // "Reset" button reloads categories
            jQuery('#reset-input').click(function() {
                container.text('');
                loadCategories(categories);
            });
        });
    }

    var initializeSearch = function(list, container, template) {
        var options = {
            caseSensitive: false,
            includeScore: true,
            shouldSort: true,
            keys: ['title', 'summary', 'description']
        };
        var fuse = new Fuse(list, options);
        var input = jQuery('#search-input');

        var onInputChange = function(query) {
            var searchResults = fuse.search(query);
            var sorted = searchResults
                .map(function(result) {
                    // round search relevance to 2 decimal places
                    result.item.relevance =
                        +(Math.round(result.score + "e+2")  + "e-2");

                    return result.item;
                });
            var record = {
                category: ('Number of search results: ' + searchResults.length),
                datasets: sorted
            }
            var renderedHtml = template(record);

            container.text('');
            container.append(renderedHtml);

            // console.log(
            //     'COUNT:', sorted.length
            // );
        };

        var lastVal = '';
        input.on('keyup', function(evt) {
            var currVal = input.val()
                .replace(/^\s+/, '')
                .replace(/\s+$/, '');

            if (lastVal !== currVal) {
                onInputChange(currVal);
                lastVal = currVal;
            }

            return true;
        });
    };

    initializeDatasets();
})
