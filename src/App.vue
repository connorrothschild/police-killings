<template>
	<div id="app">
		<div class="is-inline-flex mb-3">
			<p
				class="vertical-center is-size-4 has-text-weight-bold mr-3 mb-3-mobile"
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
		<ForceDiagram v-if="computedData.length > 0" :data="computedData" />
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
			radius: null,
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
				(d.r = self.radius), (d.x = self.w / 2);
				d.y = self.h / 2.25;
			});
			console.log(data);
			return data;
		},
	},
	methods: {
		radiusFunction: function (length) {
			if (window.innerWidth < 1000) {
				var w = this.w;
				// console.log("Small screen");
				if (length > 1000) {
					return w / 150;
				} else if (length > 500) {
					return w / 100;
				} else if (length > 250) {
					return w / 75;
				} else if (length > 120) {
					return w / 100;
				} else if (length > 100) {
					return w / 80;
				} else if (length > 80) {
					return w / 75;
				} else if (length > 60) {
					return w / 70;
				} else if (length > 40) {
					return w / 65;
				} else if (length > 20) {
					return w / 50;
				} else if (length > 10) {
					return w / 45;
				} else if (length > 5) {
					return w / 2.255;
				} else if (length <= 5) {
					return w / 2.25;
				}
			} else {
				var h = this.h;
				// console.log("Big screen");
				if (length > 1000) {
					return h / 150;
				} else if (length > 500) {
					return h / 100;
				} else if (length > 250) {
					return h / 75;
				} else if (length > 100) {
					return h / 50;
				} else if (length > 80) {
					return h / 45;
				} else if (length > 60) {
					return h / 40;
				} else if (length > 40) {
					return h / 25;
				} else if (length > 20) {
					return h / 22.5;
				} else if (length > 10) {
					return h / 25;
				} else if (length > 5) {
					return h / 15;
				} else if (length <= 5) {
					return h / 10;
				}
			}
		},
		watchResize: function () {
			this.w = window.innerWidth * 0.9;
			this.h = window.innerHeight * 0.5;
			this.radius = this.radiusFunction(this.computedData.length);
		},
	},
	created() {
		window.addEventListener("resize", debounce(this.watchResize, 150));
	},
	destroyed() {
		window.removeEventListener("resize", debounce(this.watchResize, 150));
	},
	watch: {
		computedData() {
			this.radius = this.radiusFunction(this.computedData.length);
			console.log(this.radius);
		},
		w() {
			this.radius = this.radiusFunction(this.computedData.length);
			console.log(this.radius);
		},
		h() {
			this.radius = this.radiusFunction(this.computedData.length);
			console.log(this.radius);
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
	color: #2c3e50;
	margin-top: 60px;
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
