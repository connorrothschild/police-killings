<template>
	<div class="is-flex is-justify-content-center mb-3-mobile">
		<p
			class="has-text-dark vertical-center is-size-6 has-text-weight-lighter mr-3"
		>
			Or filter by state instead:
		</p>
		<b-field style="width: 150px">
			<b-autocomplete
				size="is-small"
				rounded
				v-model="state"
				:data="filteredStateList"
				@select="
					(option) =>
						(selected = this.stateList.find((d) => d.name == option).abbr)
				"
				@typing="selected = null"
				><!-- Here, I set selected to null on type. We have to do this whenever we start off with a default value (e.g. Houston Police Deparment) -->
				<template slot="empty">No results found</template>
			</b-autocomplete>
		</b-field>
	</div>
</template>

<script>
export default {
	name: "StateSelector",
	props: {},
	data() {
		return {
			selected: "",
			state: "",
			stateList: [
				{ name: "Alabama", abbr: "AL" },
				{ name: "Alaska", abbr: "AK" },
				{ name: "Arizona", abbr: "AZ" },
				{ name: "Arkansas", abbr: "AR" },
				{ name: "California", abbr: "CA" },
				{ name: "Colorado", abbr: "CO" },
				{ name: "Connecticut", abbr: "CT" },
				{ name: "Delaware", abbr: "DE" },
				{ name: "District Of Columbia", abbr: "DC" },
				{ name: "Florida", abbr: "FL" },
				{ name: "Georgia", abbr: "GA" },
				{ name: "Hawaii", abbr: "HI" },
				{ name: "Idaho", abbr: "ID" },
				{ name: "Illinois", abbr: "IL" },
				{ name: "Indiana", abbr: "IN" },
				{ name: "Iowa", abbr: "IA" },
				{ name: "Kansas", abbr: "KS" },
				{ name: "Kentucky", abbr: "KY" },
				{ name: "Louisiana", abbr: "LA" },
				{ name: "Maine", abbr: "ME" },
				{ name: "Maryland", abbr: "MD" },
				{ name: "Massachusetts", abbr: "MA" },
				{ name: "Michigan", abbr: "MI" },
				{ name: "Minnesota", abbr: "MN" },
				{ name: "Mississippi", abbr: "MS" },
				{ name: "Missouri", abbr: "MO" },
				{ name: "Montana", abbr: "MT" },
				{ name: "Nebraska", abbr: "NE" },
				{ name: "Nevada", abbr: "NV" },
				{ name: "New Hampshire", abbr: "NH" },
				{ name: "New Jersey", abbr: "NJ" },
				{ name: "New Mexico", abbr: "NM" },
				{ name: "New York", abbr: "NY" },
				{ name: "North Carolina", abbr: "NC" },
				{ name: "North Dakota", abbr: "ND" },
				{ name: "Ohio", abbr: "OH" },
				{ name: "Oklahoma", abbr: "OK" },
				{ name: "Oregon", abbr: "OR" },
				{ name: "Pennsylvania", abbr: "PA" },
				{ name: "Rhode Island", abbr: "RI" },
				{ name: "South Carolina", abbr: "SC" },
				{ name: "South Dakota", abbr: "SD" },
				{ name: "Tennessee", abbr: "TN" },
				{ name: "Texas", abbr: "TX" },
				{ name: "Utah", abbr: "UT" },
				{ name: "Vermont", abbr: "VT" },
				{ name: "Virginia", abbr: "VA" },
				{ name: "Washington", abbr: "WA" },
				{ name: "West Virginia", abbr: "WV" },
				{ name: "Wisconsin", abbr: "WI" },
				{ name: "Wyoming", abbr: "WY" },
			],
		};
	},
	mounted() {},
	watch: {
		// * When this value changes, emit back to parent
		// ! If null, don't do anything
		selected(val) {
			// https://dev-notes.eu/2018/05/passing-data-between-vue-components/
			this.$emit("childToParent", val);
		},
	},
	computed: {
		filteredStateList() {
			const names = this.stateList.map((d) => d.name);

			return names.filter((name) => {
				return (
					name.toString().toLowerCase().indexOf(this.state.toLowerCase()) >= 0
				);
			});
		},
		stateNameToAbbr() {
			return this.selected
				? this.stateList.find((d) => d.name == this.selected).abbr
				: null;
		},
	},
	methods: {},
};
</script>

<style scoped>
</style>
