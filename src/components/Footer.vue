<template>
	<div class="foot">
		<p>
			Built by
			<a
				href="https://twitter.com/CL_Rothschild"
				target="_blank"
				rel="noopener"
			>
				Connor Rothschild</a
			>
		</p>
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
	computed: {},
	methods: {},
};
</script>

<style scoped>
.foot {
	position: fixed;
	bottom: 0;
	width: 100%;
	background-color: whitesmoke;
	color: black;
	text-align: center;
	padding: 15px 0;
}
</style>
