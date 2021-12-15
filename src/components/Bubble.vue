<template>
	<circle
		:r="r"
		:cx="cx"
		:cy="cy"
		v-on:mouseover="showTooltip"
		v-on:mouseout="hideTooltip"
		v-on:mouseenter="highlightCircle"
		v-on:mouseleave="unhighlightCircle"
		v-on:click="$emit('click')"
		v-touch="$emit('click')"
		class="circle"
	></circle>
</template>

<script>
import * as d3 from "d3";

export default {
	name: "Bubble",
	props: {
		r: Number,
		cx: Number,
		cy: Number,
	},
	watch: {},
	methods: {
		showTooltip: function (event) {
			var self = this;
			const d = event.originalTarget.__data__;

			var tooltip = d3.select("#tooltip").style("opacity", 0).attr('class', 'tooltip');

			tooltip
				.transition()
				// .delay(150)
				.duration(500)
				.style("opacity", 1);

			const tooltip_string = `<p class='title is-size-6 mb-1 has-text-centered has-text-black'> ${
				d.Name
			} </p> 
			<p class='is-size-7 has-text-centered'>${self.ageFunction(
				d.Age
			)} ${self.raceFunction(d.Race)} ${self.sexFunction(d.Sex)}.
			<p class='is-size-7 has-text-centered'>Killed by ${d[
				"Agencies responsible for death"
			].replace(/,(?=[^,]*$)/, " and")} on ${self.dateFunction(d.Date)}.`;

			tooltip
				.html(tooltip_string)
				.style(
					"left",
					event.pageX > 0.8 * this.w
						? event.pageX - 250 + "px"
						: event.pageX + 30 + "px"
				) // so that tooltip doesnt go off right side of screen
				.style("top", event.pageY - 30 + "px")
		},
		hideTooltip: function () {
			var tooltip = d3.select("#tooltip");
			tooltip.transition().duration(500).style("opacity", 0);
		},
		highlightCircle: function (event) {
			// Define a function that moves circles to the front on hover https://gist.github.com/trtg/3922684
			d3.selection.prototype.moveToFront = function () {
				return this.each(function () {
					this.parentNode.appendChild(this);
				});
			};

			const circle = event.originalTarget;
			d3.select(circle)
				.moveToFront()
				.transition()
				// .delay(150)
				.attr("r", this.r * 2);
		},
		unhighlightCircle: function (event) {
			const circle = event.originalTarget;
			d3.select(circle).transition().attr("r", this.r);
		},
		ageFunction: function (age) {
			return isNaN(age) | (age == 0) ? "A" : `A ${age} year old`;
		},
		raceFunction: function (race) {
			return (race == undefined) | (race == "Unknown Race") ? "" : race;
		},
		sexFunction: function (sex) {
			return (sex == "Male") | (sex == "Female") ? sex.toLowerCase() : "person";
		},
		pronounFunction: function (sex) {
			if (sex == "Male") {
				return "He was";
			} else if (sex == "Female") {
				return "She was";
			} else {
				return "They were";
			}
		},
		oneOfThemFunction: function (length) {
			return length == 1 ? "was that person." : "was one of them.";
		},
		dateFunction: function (date_str) {
			// h/t https://stackoverflow.com/questions/20438352/how-to-convert-date-to-words-in-html
			const months = [
				"January",
				"February",
				"March",
				"April",
				"May",
				"June",
				"July",
				"August",
				"September",
				"October",
				"November",
				"December",
			];
			// remove timezone
			const temp_date = date_str.replace("T", "-").split("-");
			return `${months[Number(temp_date[1] - 1)]} 
				${temp_date[2]}, ${temp_date[0]}`;
		},
	},
};
</script>

<style>
.circle {
	cursor: pointer;
}

.tooltip {
	min-width: 400px;
}
</style>
