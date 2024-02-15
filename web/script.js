var settingPreset = false;

// Just a wrapper for the JQ post method
const sendNuiEvent = (name, data, callback) => {
	$.post(`https://ac_radio/${name}`, JSON.stringify(data), callback);
}


// Event listeners
window.addEventListener('message', (event) => {
	const data = event.data;
	if (data.action == 'open') {
		$('.wrapper').fadeIn();
	}
});

window.addEventListener('load', () => {
	sendNuiEvent('loaded', null, (config) => {
		$('#radio-channel').attr({
			max: config.max,
			placeholder: config.max,
			min: config.step,
			step: config.step
		});

		for (const [key, value] of Object.entries(config.locales)) {
			$(`#${key.slice(3)}`).attr('tooltip', value);
		}
	});
});

window.addEventListener('keyup', (key) => {
	if (key.code == 'Escape' && $('.wrapper').is(':visible')) {
		$('.wrapper').fadeOut();
		sendNuiEvent('close');
		settingPreset = false;
	};
});


// Radio control functions
const toggleRadio = (join) => {
	var frequency = $('#radio-channel').val();
	if (join && frequency.length) {
		sendNuiEvent('join', frequency, (frequency) => {
			$('#radio-channel').val(frequency || '');
		});
	} else if (!join) {
		sendNuiEvent('leave');
		$('#radio-channel').val('');
	}
}

const changeVolume = (type) => {
	sendNuiEvent(`volume_${type}`);
}

const presetChannel = (presetId) => {
	if (settingPreset) {
		sendNuiEvent('preset_set', presetId);
		settingPreset = false;
	} else {
		sendNuiEvent('preset_join', presetId, (frequency) => {
			$('#radio-channel').val(frequency || '');
		});
	}
}

const setPreset = () => {
	var frequency = $('#radio-channel').val();
	if (frequency.length) {
		sendNuiEvent('preset_request', frequency);
		settingPreset = true;
	}
}
