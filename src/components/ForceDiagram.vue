<template>
	<section class="padding">
		<!-- Charge Strength<input
			type="range"
			min="-200"
			max="50"
			v-model="chargeStrength"
		/>
		{{ chargeStrength }}
		<br />
		Iterations<input type="range" min="1" max="10" v-model="iterations" />
		{{ iterations }}
		<br />
		Collide Strength<input
			type="range"
			min="0"
			max="2"
			v-model="collideStrength"
		/>
		{{ collideStrength }} -->
		<div class="is-inline">
			<div class="my-3">
				<a
					v-if="personSelected.text && personSelected.url"
					:href="personSelected.url"
					rel="noopener"
					target="_blank"
					v-html="personSelected.text"
				></a>
				<p v-else>Click for more information on an incident.</p>
			</div>
			<div>
				<div class="is-inline buttons has-addons">
					<button
						v-for="(item, index) in groupingVariables"
						:key="index"
						class="is-inline heading mb-0 button"
						:class="[selected === item ? 'is-dark' : '']"
						@click="splitBubbles(item)"
					>
						{{ item }}
					</button>
				</div>
			</div>
		</div>
		<div id="container">
			<svg id="diagram">
				<circle
					v-for="(item, index) in data"
					:key="index"
					:r="radius"
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
			w: window.innerWidth * 0.95,
			h: window.innerHeight * 0.65,
			simulation: null,
			svg: null,
			xStrength: 0.5,
			yStrength: 0.5,
			iterations: 1, // 1 to 10. Higher iterations = ends overlap quicker
			// chargeStrength: -2, // -200 to 50. How much "repel" there is between each circle. Higher number = greater attraction
			collideStrength: 1, // 0 to 2.
			groupingVariables: [
				"All",
				"Race",
				"Sex",
				"Armed Status",
				"Cause of death",
				"Year",
			],
			selected: "All", // Current selected button
			personSelected: { text: null, url: null }, // Default null until the user clicks on a person
		};
	},
	mounted() {
		this.instantiate();
	},
	computed: {
		chargeStrength() {
			// * If radius <= 5 (which means length > 100), make negative
			return this.radius <= 5 ? -this.radius / 2 : 1; // else positive
		},
		// centerScale() {
		// 	return d3.scalePoint().padding(0.8).range([0, this.w]);
		// },
	},
	methods: {
		instantiate: function () {
			this.w = window.innerWidth * 0.95;
			this.h = window.innerHeight * 0.65;

			this.simulation = d3
				.forceSimulation(this.data)
				.force(
					"collide",
					d3
						.forceCollide()
						.radius(this.radius)
						.strength(this.collideStrength)
						.iterations(this.iterations)
				)
				.force("charge", d3.forceManyBody().strength(this.chargeStrength))
				.force(
					"y",
					d3.forceY().y(this.h / 2)
					// .strength(this.yStrength)
				)
				.force(
					"x",
					d3.forceX().x(this.w / 2)
					// .strength(this.xStrength)
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
				.style("stroke-width", 1)
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
		splitBubbles: function (group) {
			this.selected = group;

			if (group == "All") {
				this.groupBubbles();
			} else {
				this.centerScale = d3.scalePoint().padding(0.8).range([0, this.w]);
				const data = this.data;

				this.centerScale.domain(
					data.map(function (d) {
						return d[group];
					})
				);

				// console.log(centerScale.domain());
				this.showTitles(this.centerScale);

				this.simulation
					.force(
						"x",
						d3.forceX().x((d) => this.centerScale(d[group]))
					)
					.force("charge", d3.forceManyBody().strength(this.chargeStrength));

				this.simulation.alpha(1).restart();

				this.svg
					.selectAll("circle")
					.data(this.data)
					.attr("r", this.radius)
					.style("fill", (d) => this.colorScale(d.Race));
			}
		},
		groupBubbles: function () {
			this.hideTitles();

			this.simulation.force("x", d3.forceX().x(this.w / 2));
			this.simulation.alpha(1).restart();
		},
		changeText: function (event) {
			const d = event.originalTarget.__data__;

			d.Name = d.Name == "Name withheld by police" ? "this victim" : d.Name;

			this.personSelected.text = `Take me to a news article describing <span class='inline-link'>${d.Name}</span>'s death.`;
			this.personSelected.url = d.Link;
		},
		showTooltip: function (event) {
			var self = this;
			const d = event.originalTarget.__data__;

			var tooltip = d3.select("#tooltip").style("opacity", 0);

			tooltip.transition().delay(150).duration(500).style("opacity", 1);

			// const tooltip_string = `<span class='has-text-weight-bold'>
			// ${d.Name} </span> was
			// ${self.ageFunction(d.Age)} ${self.raceFunction(d.Race)} ${d.Sex.toLowerCase()}.
			// <br>
			// ${self.pronounFunction(d.Sex)} killed by ${d["Cause of death"]
			// 	.toLowerCase()
			// 	.replace(/,(?=[^,]*$)/, " and")}
			// by the ${d["Agencies responsible for death"].replace(/,(?=[^,]*$)/, " and")}
			// on ${self.dateFunction(d.Date)}.`;

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
				.style("top", event.pageY - 30 + "px");
		},
		showTitles: function (scale) {
			// * A rather big method
			// Here, we create a series of text labels, one for each group, that each have a rectangle behind them
			// The rectangle's width is responsive to the text length, using this.getComputedTextLength
			// https://stackoverflow.com/questions/29031659/calculate-width-of-text-before-drawing-the-text

			// Destructure svg for convenient use
			const { svg } = this;

			// textData will equal the groups (e.g. for race: ['Black', 'White', 'Asian', 'Hispanic', 'Unknown Race'])
			const textData = scale.domain();

			// textWidth will be populated later width px widths, depending on text length
			let textWidth = [];

			// Define some constants
			const LABEL_POS = 40; // Y position of labels
			const RECT_HEIGHT = 30;

			// Instantiate groups
			const titles = svg.selectAll(".label-text").data(textData);
			const rects = svg.selectAll(".rect").data(textData);

			// * Here is where we populate textWidth
			// Note: we're not actually appending anything here, just getting text widths
			svg
				.append("g")
				.selectAll(".dummyText")
				.data(textData)
				.enter()
				.append("text")
				.attr("class", "label-text")
				.text((d) => d)
				// For each element, get its text length and push it to array
				.each(function () {
					var thisWidth = this.getComputedTextLength() * 1.2;
					textWidth.push(thisWidth);
					this.remove(); // Then, remove so they don't display
				});

			// Create rectangles with responsive widths
			rects
				.enter()
				.append("rect")
				.attr("class", "rect")
				.merge(rects)
				.attr("x", (d) => scale(d))
				.attr("rx", 5)
				// If there are 4+ groups, stagger y position slightly
				.attr("y", (d, i) =>
					textData.length > 4 ? (i % 2 ? LABEL_POS * 2 : LABEL_POS) : LABEL_POS
				)
				// eslint-disable-line no-unused-vars
				.attr("transform", (d, i) => `translate(-${textWidth[i] / 2}, -20)`) // Rect should be centered, hence textWidth/2
				// eslint-disable-line no-unused-vars
				.attr("width", (d, i) => textWidth[i])
				.attr("height", RECT_HEIGHT)
				.style("fill", "#F5F5F5")
				.style("opacity", 0.95);

			// ! TODO: add # of obs after text (e.g. "Unarmed (6 people)")

			// Add REAL text
			titles
				.enter()
				.append("text")
				.attr("class", "label-text")
				.merge(titles)
				.attr("x", (d) => scale(d))
				.attr("y", (d, i) =>
					textData.length > 4 ? (i % 2 ? LABEL_POS * 2 : LABEL_POS) : LABEL_POS
				)
				.text((d) => d)
				.attr("text-anchor", "middle");

			rects.moveToFront();
			titles.moveToFront();

			// Exit remove pattern so that the labels update on group change
			titles.exit().remove();
			rects.exit().remove();
		},
		hideTitles: function () {
			this.svg.selectAll(".label-text").remove();
			this.svg.selectAll(".rect").remove();
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
		locFunction: function (selected_loc) {
			return selected_loc.trim() == ""
				? "Houston Police Department (TX)"
				: selected_loc;
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
		watchResize: function () {
			this.selected = "All";
			// this.hideTitles();

			this.w = window.innerWidth * 0.95;
			this.h = window.innerHeight * 0.65;

			this.svg.attr("width", this.w).attr("height", this.h);

			// this.centerScale;
			this.groupBubbles();
		},
	},
	created() {
		window.addEventListener("resize", debounce(this.watchResize, 500));
	},
	destroyed() {
		window.removeEventListener("resize", debounce(this.watchResize, 500));
	},
	watch: {},
};
</script>

<style>
.tooltip {
	background-color: white;
	position: absolute;
	text-align: left;
	padding: 0.5rem;
	border-radius: 8px;
	pointer-events: none;
	border: 1px solid #e0e0e0;
	display: block;
	max-width: 350px;
}

.flex-grow {
	flex-grow: 1;
}

a[href] {
	color: black;
}

.inline-link {
	padding: 3px;
	border-radius: 3px;
	background: #e5e5e5;
}

.label-text {
	font-size: 1em;
}

@media screen and (max-width: 600px) {
	.label-text {
		font-size: 0.5em;
	}
}

.padding {
	padding: 0 2.5%;
}

.input:active {
	border-color: black;
}
</style>
