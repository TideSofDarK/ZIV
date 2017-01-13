function Blur() {
	$.GetContextPanel().AddClass("Blur");
}

function RemoveBlur() {
	$.GetContextPanel().RemoveClass("Blur");
}

function BlackAndWhite() {
	$.GetContextPanel().AddClass("BlackAndWhite");
}

function RemoveBlackAndWhite() {
	$.GetContextPanel().RemoveClass("BlackAndWhite");
}

(function () {
	GameEvents.Subscribe("ziv_add_blur", function () {
		Blur()
	})
	GameEvents.Subscribe("ziv_remove_blur", function () {
		RemoveBlur() 
	})
	GameEvents.Subscribe("ziv_add_black_and_white", function () {
		BlackAndWhite()
	})
	GameEvents.Subscribe("ziv_remove_black_and_white", function () {
		RemoveBlackAndWhite();
	})
})();