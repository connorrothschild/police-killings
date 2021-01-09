<template>
	<div class="subtitle has-text-dark mt-2 px-1">
		<p>
			Between 2013 and 2020, the {{ selected }} killed
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
