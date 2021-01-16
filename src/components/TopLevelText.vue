<template>
	<div class="subtitle is-size-6-mobile mt-2 px-1">
		<p class="has-text-black">
			Between 2013 and 2021, the
			{{ this.filterType == "state" ? selected + " police " : selected }} killed
			<span class="has-text-weight-semibold"
				>{{ dataLength }} {{ this.personFunction }}</span
			>.
		</p>
		<div class="mt-2">
			<a
				v-if="personSelected"
				:href="personSelected.url"
				target="_blank"
				rel="noopener noreferrer"
				class="inline-link"
			>
				<span v-if="personSelected.name == 'this victim'"
					>This victim's name was withheld by police. &#x2197;</span
				>
				<span v-else
					><span class="has-text-weight-bold"
						>{{ personSelected.name }} &#x2197;</span
					>
					was one of them.</span
				>
			</a>
			<p v-else>Do you know their {{ this.namePlural }}?</p>
		</div>
	</div>
</template>

<script>
export default {
	name: "TopLevelText",
	props: {
		dataLength: Number,
		selected: String,
		filterType: String,
		personSelected: Object,
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
.inline-link {
	color: #0000ee;
	text-decoration: underline;
	/* padding: 3px;
	border-radius: 3px;
	background: #e5e5e5; */
}
</style>
