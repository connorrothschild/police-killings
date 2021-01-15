<template>
	<div class="subtitle is-size-6-mobile has-text-dark mt-2 px-1">
		<p>
			Between 2013 and 2021, the
			{{ this.filterType == "state" ? selected + " police " : selected }} killed
			<span class="has-text-weight-semibold"
				>{{ dataLength }} {{ this.personFunction }}</span
			>.
		</p>
		<p>Do you know their {{ this.namePlural }}?</p>
	</div>
</template>

<script>
export default {
	name: "TopLevelText",
	props: {
		dataLength: Number,
		selected: String,
		filterType: String,
	},
	data() {
		return {};
	},
	mounted() {},
	watch: {},
	computed: {
		personFunction: function () {
			return this.dataLength == 1 ? "person" : "people";
		},
		namePlural: function () {
			return this.dataLength > 1 ? "names" : "name";
		},
	},
	methods: {},
};
</script>

<style scoped>
</style>
