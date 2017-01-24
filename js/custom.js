$(document).ready(function () {

	$('.new_comment_button').click(function() {

		alert("코멘트를 작성합니다.");
		var formId = $(this).attr('formId');
		var thisForm = $(formId);
		var formData = thisForm.serializeArray();
		var fieldsWithErrors = [];

		$(formData).each((function (index, element) {
			var required = thisForm.find('[name="' + element.name + '"]').attr('required');
			var empty = (element.value.trim().length === 0);

			if (required && empty) {
				fieldsWithErrors.push(element.name);
			}
		}).bind(this));
		var addAt = "#comment_hidden_" + thisForm.attr('slug');
		if (fieldsWithErrors.length === 0) {
			var postUrl = thisForm.attr('action');
			var payload = $.param(formData);

			$.ajax({
				type: 'POST',
				url: postUrl,
				dataType : 'json',
				data: payload,
				success: function (response) {
					var comment = getComment(response);
					addComment(comment, addAt);
				},
				error: function (response) {
					console.log('** ERROR!');
					console.log(response);
				}
			});

			thisForm.get(0).reset();
		}

		return false;
	});
});

function getComment(data) {
	var template = $('#template-comment').text();
	data.index = "999";
	for (var variable in data) {
		var exp = new RegExp('{' + variable + '}', 'g');
		template = template.replace(exp, data[variable]);
	}

	return template;
}

function addComment(comment, addAt) {
	$(addAt).removeAttr('aria-hidden').append(comment);
}


function comment_toggle(id, txt)
{
	var obj=document.getElementById(id);

	if(obj.style.display == "none") {
	  obj.style.display="inline";
	}
	else {
	  obj.style.display="none";
	}

}
