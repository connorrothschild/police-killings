<template>
	<section>
		<div id="container">
			<svg id="diagram">
				<circle
					v-for="(item, index) in data"
					:key="index"
					:r="item.r"
					:cx="item.x"
					:cy="item.y"
					@click="changeText"
					@mouseover="showTooltip"
					@mouseout="hideTooltip"
					@mouseenter="highlightCircle"
					@mouseleave="unhighlightCircle"
				/>
			</svg>
			<div id="tooltip" class="tooltip"></div>
		</div>
	</section>
</template>

<script>
import * as d3 from "d3";
import debounce from "lodash/debounce";

export default {
	name: "ForceDiagram",
	props: {
		data: Array,
		radius: Number,
	},
	data() {
		return {
			w: window.innerWidth * 0.9,
			h: window.innerHeight * 0.5,
			simulation: null,
			svg: null,
		};
	},
	mounted() {
		console.log("Instantiated Force Diagram");
		const r = this.radius;
		console.log(r);
		this.simulation = d3
			.forceSimulation(this.data)
			.force("collide", d3.forceCollide(r).iterations(2)) // iterations changes the duration before circles stop overlapping
			.force("charge", d3.forceManyBody().strength(0.5))
			.force(
				"y",
				d3
					.forceY()
					.y(this.h / 2)
					.strength(0.1)
			)
			.force(
				"x",
				d3
					.forceX()
					.x(this.w / 2)
					.strength(0.1)
			)
			.on("tick", ticked);

		this.svg = d3
			.select("#diagram")
			.attr("width", this.w)
			.attr("height", this.h);

		const circles = this.svg
			.selectAll("circle")
			.data(this.data)
			.attr("r", this.radius)
			.style("stroke", "black")
			.style("fill", (d) => this.colorScale(d.Race))
			.style("stroke-width", 2)
			.style("pointer-events", "all");

		function ticked() {
			circles.attr("cx", (d) => d.x).attr("cy", (d) => d.y);
		}

		// Define a function that moves circles to the front on hover https://gist.github.com/trtg/3922684
		d3.selection.prototype.moveToFront = function () {
			return this.each(function () {
				this.parentNode.appendChild(this);
			});
		};

		this.simulation.nodes(this.data).on("tick", ticked).alpha(1).restart();
	},
	computed: {},
	methods: {
		changeText: function (event) {
			const d = event.originalTarget.__data__;
			console.log("Looking at", d.Name);
		},
		showTooltip: function (event) {
			var self = this;
			const d = event.originalTarget.__data__;

			var tooltip = d3.select("#tooltip").style("opacity", 0);

			tooltip.transition().delay(150).duration(500).style("opacity", 1);

			const tooltip_string = `<span class='has-text-weight-bold'> 
			${d.Name} </span> was
			${self.ageFunction(d.Age)} ${d.Race} ${d.Sex.toLowerCase()}.
			<br>
			${self.pronounFunction(d.Sex)} killed by ${d["Cause of death"]
				.toLowerCase()
				.replace(/,(?=[^,]*$)/, " and")}
			by the ${d["Agencies responsible for death"].replace(/,(?=[^,]*$)/, " and")} 
			on ${self.dateFunction(d.Date)}.`;

			tooltip
				.html(tooltip_string)
				.style("left", event.pageX + 30 + "px")
				.style("top", event.pageY - 30 + "px");
		},
		hideTooltip: function () {
			var tooltip = d3.select("#tooltip");
			tooltip.transition().duration(500).style("opacity", 0);
		},
		highlightCircle: function (event) {
			const circle = event.originalTarget;
			d3.select(circle)
				.moveToFront()
				.transition()
				.delay(150)
				.attr("r", this.radius * 2);
		},
		unhighlightCircle: function (event) {
			const circle = event.originalTarget;
			d3.select(circle).transition().attr("r", this.radius);
		},
		colorScale: function (race) {
			const color = d3
				.scaleOrdinal()
				.domain([
					"Black",
					"White",
					"Asian",
					"Hispanic",
					"Unknown Race",
					"Unknown race",
					"Pacific Islander",
					"Native American",
				])
				.range([
					"#BE3137",
					"#FFC600",
					"#59B359",
					"#4E070C",
					"#7B48AD",
					"#7B48AD",
					"#E96200",
					"#5F96CE",
				]);
			return color(race);
		},
		ageFunction: function (age) {
			return isNaN(age) | (age == 0) ? "an unknown age " : `a ${age} year old`;
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
		locFunction: function (selected_loc) {
			return selected_loc.trim() == ""
				? "Houston Police Department (TX)"
				: selected_loc;
		},
		dateFunction: function (date_str) {
			// // h/t https://stackoverflow.com/questions/20438352/how-to-convert-date-to-words-in-html
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
		watchResize: function () {
			this.w = window.innerWidth * 0.9;
			this.h = window.innerHeight * 0.5;

			this.simulation
				.force("collide", d3.forceCollide(this.radius).iterations(2)) // iterations changes the duration before circles stop overlapping
				.force("charge", d3.forceManyBody().strength(0.5))
				.force(
					"y",
					d3
						.forceY()
						.y(this.h / 2)
						.strength(0.1)
				)
				.force(
					"x",
					d3
						.forceX()
						.x(this.w / 2)
						.strength(0.1)
				)
				.alpha(1)
				.restart();

			this.svg
				.attr("width", this.w)
				.attr("height", this.h)
				.selectAll("circle")
				.data(this.data)
				.attr("r", this.radius);
		},
	},
	created() {
		window.addEventListener("resize", debounce(this.watchResize, 150));
	},
	destroyed() {
		window.removeEventListener("resize", debounce(this.watchResize, 150));
	},
};
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.tooltip {
	background-color: white;
	position: absolute;
	text-align: left;
	padding: 4px;
	border-radius: 8px;
	pointer-events: none;
	border: 1px solid #e0e0e0;
	display: block;
}
</style>
