<template>
	<div class="is-inline-flex mb-3-mobile">
		<p
			class="has-text-black vertical-center is-size-4 has-text-weight-bold mr-3 mb-3 mr-0-mobile"
		>
			Police Killings by the
		</p>
		<b-field style="min-width: 350px">
			<b-autocomplete
				rounded
				v-model="department"
				:data="filteredDepartmentList"
				placeholder="Houston Police Department (TX)"
				@select="(option) => (selected = option)"
				@typing="selected = null"
				><!-- Here, I set selected to null on type. We have to do this whenever we start off with a default value (e.g. Houston Police Deparment) -->
				<template slot="empty">No results found</template>
			</b-autocomplete>
		</b-field>
	</div>
</template>

<script>
export default {
	name: "DepartmentSelector",
	props: { departments: Array },
	data() {
		return {
			selected: "Houston Police Department (TX)", // null
			department: "",
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
		filteredDepartmentList() {
			return this.departments.filter((option) => {
				return (
					option
						.toString()
						.toLowerCase()
						.indexOf(this.department.toLowerCase()) >= 0
				);
			});
		},
	},
	methods: {},
};
</script>

<style scoped>
</style>
