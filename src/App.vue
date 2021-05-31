<template>
	<div id="app">
		<div class="pt-5 pb-4">
			<DepartmentSelector
				:departments="departments"
				v-on:childToParent="receiveDepartmentName"
			/>
			<br />
			<StateSelector v-on:childToParent="receiveStateName" />
			<TopLevelText
				v-if="computedData.length > 0 && selected"
				:dataLength="computedData.length"
				:selected="selected"
				:filterType="filterType"
				:personSelected="personSelected"
			/>
		</div>
		<ForceDiagram
			v-if="computedData.length > 0 && selected"
			:data="computedData"
			:radius="radius"
			v-on:childToParent="receivePersonSelected"
		/>
		<Footer />
	</div>
</template>

<script>
import * as d3 from "d3";
import ForceDiagram from "@/components/ForceDiagram.vue";
import DepartmentSelector from "@/components/DepartmentSelector.vue";
import StateSelector from "@/components/StateSelector.vue";
import TopLevelText from "@/components/TopLevelText.vue";
import Footer from "@/components/Footer.vue";
import debounce from "lodash/debounce";

export default {
	name: "App",
	components: {
		ForceDiagram,
		StateSelector,
		DepartmentSelector,
		TopLevelText,
		Footer,
	},
	data() {
		return {
			killings: [],
			departments: [],
			w: window.innerWidth * 0.95,
			h: window.innerHeight * 0.5,
			radius: null,
			selected: "Houston Police Department (TX)",
			filterType: "department",
			personSelected: null,
		};
	},
	async mounted() {
		const killings = await d3.csv("./data/cleaned.csv");
		this.killings = killings;

		const departments = await d3.csv("./data/departments.csv");
		this.departments = departments.map((d) => d.all_agencies);
	},
	computed: {
		filteredData() {
			let data;
			if (this.filterType == "department") {
				data = this.killings.filter((d) =>
					d["Agency responsible for death"].includes(this.selected)
				);
			} else if (this.filterType == "state") {
				data = this.killings.filter((d) => d.State.includes(this.selected));
			}
			return data;
		},
		computedData() {
			var self = this;
			var data = this.filteredData;
			data.forEach(function (d) {
				d.Age = +d.Age;
				d.x = self.w / 2;
				d.y = self.h / 2;
			});

			return data;
		},
		radiusFunction() {
			const length = this.computedData.length;
			var w = this.w;
			var h = this.h;

			let canvasSize = w * 2 + h * 2;
			let r;
			if (length > 1000) {
				r = (canvasSize / length) * 2;
			} else if (length > 500) {
				r = canvasSize / length;
			} else if (length > 200) {
				r = canvasSize / length / 3;
			} else if (length > 100) {
				r = canvasSize / length / 4;
			} else if (length > 50) {
				r = canvasSize / length / 5;
			} else if (length > 25) {
				r = canvasSize / length / 7.5;
			} else if (length > 10) {
				r = canvasSize / length / 10;
			} else {
				r = canvasSize / length / 12.5;
			}

			return r;
		},
	},
	methods: {
		watchResize: function () {
			this.w = window.innerWidth * 0.9;
			this.h = window.innerHeight * 0.5;
			this.radius = this.radiusFunction;
		},
		receiveStateName(value) {
			this.filterType = "state";
			this.selected = value;
			// On state or department change, we need to clear top level text that has a name
			this.personSelected = null;
		},
		receiveDepartmentName(value) {
			this.filterType = "department";
			this.selected = value;
			// On state or department change, we need to clear top level text that has a name
			this.personSelected = null;
		},
		receivePersonSelected(value) {
			this.personSelected = value;
		},
	},
	created() {
		window.addEventListener("resize", debounce(this.watchResize, 1000));
	},
	destroyed() {
		window.removeEventListener("resize", debounce(this.watchResize, 1000));
	},
	watch: {
		computedData() {
			this.radius = this.radiusFunction;
		},
		w() {
			this.radius = this.radiusFunction;
		},
		h() {
			this.radius = this.radiusFunction;
		},
	},
};
</script>

<style>
#app {
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica,
		Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	text-align: center;
	color: black;
}

html {
	-ms-touch-action: manipulation;
	touch-action: manipulation;
}

.vertical-center {
	align-self: center;
}

@media screen and (max-width: 768px) {
	.is-inline-flex {
		flex-direction: column;
	}

	.mb-3-mobile {
		margin-right: 0 !important;
		margin-bottom: 0.75rem !important;
	}
}

.input {
	text-align: center;
}
</style>
