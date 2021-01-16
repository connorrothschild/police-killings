import Vue from 'vue';
import App from './App.vue';
import Buefy from 'buefy';
import 'buefy/dist/buefy.css';
import Vue2TouchEvents from 'vue2-touch-events';

Vue.use(Vue2TouchEvents);
Vue.use(Buefy);

Vue.config.productionTip = false;

new Vue({
	render : (h) => h(App)
}).$mount('#app');
