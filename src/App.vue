<template>
	<div id="app">
		<!-- <div class="section has-background-light"></div> -->
		<div class="has-background-light py-5">
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
						placeholder="e.g. Houston Police Department"
						@select="(option) => (selected = option)"
					>
						<template slot="empty">No results found</template>
					</b-autocomplete>
				</b-field>
			</div>
			<TopLevelText
				v-if="selected"
				:dataLength="computedData.length"
				:selected="selected"
			/>
		</div>
		<ForceDiagram
			v-if="computedData.length > 0"
			:data="computedData"
			:radius="radiusFunction"
		/>
	</div>
</template>

<script>
import * as d3 from "d3";
import ForceDiagram from "@/components/ForceDiagram.vue";
import TopLevelText from "@/components/TopLevelText.vue";
import debounce from "lodash/debounce";

export default {
	name: "App",
	components: {
		ForceDiagram,
		TopLevelText,
	},
	data() {
		return {
			killings: [],
			departments: [],
			name: "",
			selected: null,
			w: window.innerWidth * 0.9,
			h: window.innerHeight * 0.5,
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
		filteredData() {
			const dataFiltered = this.killings.filter((d) =>
				d["Agency responsible for death"].includes(this.selected)
			);
			return dataFiltered;
		},
		computedData() {
			var self = this;
			const data = this.filteredData;

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
			let r = length < 50 ? 20 : canvasSize / length / 4;

			console.log([w, h]);
			console.log(r);

			return r;
		},
	},
	methods: {
		watchResize: function () {
			this.w = window.innerWidth * 0.9;
			this.h = window.innerHeight * 0.5;
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
			console.log(
				"Radius is",
				this.radiusFunction,
				". Changed because computedData.length changed"
			);
		},
		w() {
			console.log(
				"Radius is",
				this.radiusFunction,
				". Changed because width changed"
			);
		},
		h() {
			console.log(
				"Radius is",
				this.radiusFunction,
				". Changed because height changed"
			);
		},
	},
};
</script>

<style>
#app {
	font-family: Avenir, Helvetica, Arial, sans-serif;
	-webkit-font-smoothing: antialiased;
	-moz-osx-font-smoothing: grayscale;
	text-align: center;
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

.spacer {
	height: 5vh;
}
</style>
