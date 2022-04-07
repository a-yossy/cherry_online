import Sortable from "sortablejs";
import Rails from "@rails/ujs";

$(function () {
    const el = document.getElementById('pages');
    Sortable.create(el, {
        animation: 200,
        onUpdate: function (evt) {
            const item_data = evt.item.children[0].dataset;
            $.ajax({
                type: 'PUT',
                url: item_data.updateUrl,
                headers: {
                    'X-CSRF-Token': Rails.csrfToken()
                },
                dataType: 'json',
                data: { page: { page_order_position: evt.newIndex } }
            });
        }
    });
});
