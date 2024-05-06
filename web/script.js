let settingPreset = false;

const sendNuiEvent = (name, data, callback) => {
	$.post(`https://ac_radio/${name}`, JSON.stringify(data), callback);
}

const setLocale = (locales) => {
	for (const [key, value] of Object.entries(locales)) {
		$(`#${key.slice(3)}`).attr('tooltip', value);
	}
}

const closeUi = () => {
	$('.wrapper').fadeOut();
	settingPreset = false;
}



// event listeners
window.addEventListener('message', (event) => {
	const { action, data } = event.data;

	if (action == 'openUi') {
		$('.wrapper').fadeIn();
	} else if (action == 'setLocale') {
		setLocale(data);
	} else if (action == 'closeUi') {
		closeUi();
	}
});

window.addEventListener('load', () => {
	sendNuiEvent('getConfig', null, (config) => {
		$('#radio-channel').attr({
			max: config.max,
			placeholder: config.max,
			min: config.step,
			step: config.step
		});

		setLocale(config.locales);
	});
});

window.addEventListener('keyup', (key) => {
	if (key.code == 'Escape' && $('.wrapper').is(':visible')) {
		sendNuiEvent('closeUi');
		closeUi();
	};
});



// radio control functions
const toggleRadio = (join) => {
	let frequency = $('#radio-channel').val();
	if (join && frequency.length) {
		sendNuiEvent('joinFrequency', frequency, (frequency) => {
			$('#radio-channel').val(frequency || '');
		});
	} else if (!join) {
		sendNuiEvent('leaveFrequency');
		$('#radio-channel').val('');
	}
}

const presetChannel = (presetId) => {
	if (settingPreset) {
		sendNuiEvent('presetSet', presetId);
		settingPreset = false;
	} else {
		sendNuiEvent('presetJoin', presetId, (frequency) => {
			$('#radio-channel').val(frequency || '');
		});
	}
}

const setPreset = () => {
	let frequency = $('#radio-channel').val();
	if (frequency.length) {
		sendNuiEvent('presetRequest', frequency);
		settingPreset = true;
	}
}
