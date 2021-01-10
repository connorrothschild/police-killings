<template>
	<div id="app">
		<div class="has-background-light pt-5 pb-4">
			<!-- <div class="pt-5 pb-4"> -->
			<div class="is-inline-flex mb-3-mobile">
				<p
					class="has-text-black vertical-center is-size-4 has-text-weight-bold mr-3 mb-3 mr-0-mobile"
				>
					Police Killings by the
				</p>
				<b-field style="min-width: 350px">
					<b-autocomplete
						rounded
						v-model="name"
						:data="filteredDepartmentList"
						placeholder="Houston Police Department (TX)"
						@select="(option) => (selected = option)"
						@typing="selected = null"
						><!-- Here, I set selected to null on type. We have to do this whenever we start off with a default value (e.g. Houston Police Deparment) -->
						<template slot="empty">No results found</template>
					</b-autocomplete>
				</b-field>
			</div>
			<br />
			<StateSelector />
			<TopLevelText
				v-if="computedData.length > 0 && selected"
				:dataLength="computedData.length"
				:selected="selected"
			/>
		</div>
		<ForceDiagram
			v-if="computedData.length > 0 && selected"
			:data="computedData"
			:radius="radius"
		/>
		<Footer />
	</div>
</template>

<script>
import * as d3 from "d3";
import ForceDiagram from "@/components/ForceDiagram.vue";
import StateSelector from "@/components/StateSelector.vue";
import TopLevelText from "@/components/TopLevelText.vue";
import Footer from "@/components/Footer.vue";
import debounce from "lodash/debounce";

export default {
	name: "App",
	components: {
		ForceDiagram,
		StateSelector,
		TopLevelText,
		Footer,
	},
	data() {
		return {
			killings: [],
			departments: [],
			name: "",
			selectedState: null,
			selected: "Houston Police Department (TX)", // null
			w: window.innerWidth * 0.9,
			h: window.innerHeight * 0.5,
			radius: 10,
		};
	},
	async mounted() {
		const killings = await d3.csv("/data/cleaned_data.csv");
		this.killings = killings;

		const departments = await d3.csv("/data/department_data.csv");
		this.departments = departments.map((d) => d.all_agencies);
	},
	computed: {
		filteredDepartmentList() {
			return this.departments.filter((option) => {
				return (
					option.toString().toLowerCase().indexOf(this.name.toLowerCase()) >= 0
				);
			});
		},
		stateList() {
			return this.killings.map((d) => d.State);
		},
		filteredData() {
			return this.killings.filter((d) =>
				d["Agency responsible for death"].includes(this.selected)
			);
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
			// canvasSize cannot be smaller than (r * 2) * this.computedData.length
			// human terms: bubble diameter * number of bubbles
			// algebra: (canvasSize/this.computedData.length) / 2 == r
			// but because space isnt evenly distributed in canvas, even this doesn't work exactly
			// divide by 4 just to be safe (rather too small than too large!)

			const length = this.computedData.length;
			var w = this.w;
			var h = this.h;

			let canvasSize = w * 2 + h * 2;

			// FIXME: Need better (?) way to handle small lengths
			let r = length < 50 ? 10 : canvasSize / length / 4;

			console.log([w, h]);
			console.log(r);

			return r;
		},
	},
	methods: {
		watchResize: function () {
			this.w = window.innerWidth * 0.9;
			this.h = window.innerHeight * 0.5;
			this.radius = this.radiusFunction;
			console.log("Hello", this.radius);
		},
	},
	created() {
		window.addEventListener("resize", debounce(this.watchResize, 500));
	},
	destroyed() {
		window.removeEventListener("resize", debounce(this.watchResize, 500));
	},
	watch: {
		computedData() {
			this.radius = this.radiusFunction;
			console.log(
				"Radius is",
				this.radius,
				". Changed because computedData changed"
			);
		},
		w() {
			this.radius = this.radiusFunction;
			console.log("Radius is", this.radius, ". Changed because width changed");
		},
		h() {
			this.radius = this.radiusFunction;
			console.log("Radius is", this.radius, ". Changed because height changed");
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
</style>
