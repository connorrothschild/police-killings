<template>
	<section>
		<div class="is-inline">
			<p class="my-3">Click for more information on an incident</p>
			<div>
				<div class="is-inline buttons has-addons">
					<button
						v-for="(group, index) in groupingVariables"
						v-bind:key="index"
						@click="splitBubbles(group)"
						class="button"
					>
						{{ group }}
					</button>
					<!-- FIXME: can't get 						
 v-bind:class="[selected === group ? 'has-text-light is-selected' : '',]" 
 to work -->
				</div>
			</div>
		</div>
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
			xStrength: 0.1,
			yStrength: 0.5,
			chargeStrength: 20, // How much "repel" there is between each circle
			groupingVariables: [
				"All",
				"Race",
				"Sex",
				"Armed Status",
				"Cause of death",
				"Year",
			],
			selected: "Race", // Current selected button
		};
	},
	mounted() {
		console.log("Instantiated Force Diagram");

		const r = this.radius;
		this.simulation = d3
			.forceSimulation(this.data)
			.force("collide", d3.forceCollide(r).iterations(2)) // iterations changes the duration before circles stop overlapping
			.force("charge", d3.forceManyBody().strength(this.chargeStrength))
			.force(
				"y",
				d3
					.forceY()
					.y(this.h / 2)
					.strength(this.yStrength)
			)
			.force(
				"x",
				d3
					.forceX()
					.x(this.w / 2)
					.strength(this.xStrength)
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
	computed: {
		centerScale() {
			return d3.scalePoint().padding(0.8).range([0, this.w]);
		},
	},
	methods: {
		splitBubbles: function (group) {
			this.selected = group;
			const centerScale = this.centerScale;
			const data = this.data;

			centerScale.domain(
				data.map(function (d) {
					return d[group];
				})
			);

			if (group == "All") {
				groupBubbles();
			} else {
				// showTitles(group, this.centerScale);

				this.simulation.force(
					"x",
					d3
						.forceX()
						.strength(0.2)
						.x((d) => centerScale(d[group]))
				);

				this.simulation.alpha(1).restart();
			}
		},
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
			${self.ageFunction(d.Age)} ${self.raceFunction(d.Race)} ${d.Sex.toLowerCase()}.
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
		raceFunction: function (race) {
			return (race == undefined) | (race == "Unknown Race")
				? "unknown race"
				: race;
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
				.force("charge", d3.forceManyBody().strength(this.chargeStrength))
				.alpha(1)
				.force(
					"y",
					d3
						.forceY()
						.y(this.h / 2)
						.strength(this.yStrength)
				)
				.force(
					"x",
					d3
						.forceX()
						.x(this.w / 2)
						.strength(this.xStrength)
				)
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
		window.addEventListener("resize", debounce(this.watchResize, 1000));
	},
	destroyed() {
		window.removeEventListener("resize", debounce(this.watchResize, 1000));
	},
};
</script>

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

.flex-grow {
	flex-grow: 1;
}
</style>
