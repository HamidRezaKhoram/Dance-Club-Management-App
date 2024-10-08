<script setup lang="ts">
import {useRouter, useRoute} from 'vue-router';
import {ref, onMounted} from 'vue';
import Button from 'primevue/button';
import Toast from 'primevue/toast';
import {useToast} from "primevue/usetoast";
import {useAuthStore} from '@/stores/authStore'


const toast = useToast();

const cardName = ref('');
const cardNumber = ref('');
const expiry = ref('');
const securityCode = ref('');
const postalCode = ref('');
const paymentAmount = ref('');
const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

async function submitPayment() {
    let errorMessage = '';
    if (!cardName.value) errorMessage += 'Name on card is required. ';
    // Update this line to check for exactly 16 digits
    if (!/^\d{16}$/.test(cardNumber.value)) errorMessage += 'Card number must be 16 digits and numeric. ';
    if (securityCode.value.length !== 3) errorMessage += 'Security code must be 3 digits. ';
    if (postalCode.value.length < 5 || postalCode.value.length > 8) errorMessage += 'Postal code must be between 5 and 8 characters. ';

    if (errorMessage) {
        toast.add({severity: 'error', summary: 'Payment Error', detail: errorMessage.trim(), life: 3000});
        return;
    }

    const rawResponse = await fetch(`/api/user/${authStore.id}/pay`, {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({email: authStore.email, amount: parseInt(paymentAmount.value), in_advance_payment: true})
    });
    if (rawResponse.ok) {
        await authStore.pushToast('success', 'Payment Successful', 'Payment processed successfully')
        await authStore.refreshOwed();
        await router.push('/user/dashboard')
    } else {
        const body = await rawResponse.json();
        toast.add({severity: 'error', summary: body.error, detail: body.error, life: 3000});
    }
}


onMounted(() => {
    // Fetch the query parameter and assign it to paymentAmount
    paymentAmount.value = (route.query.amount || '').toString();
});


</script>

<template>
    <div
        class="flex flex-col items-center justify-center max-w-sm mx-auto my-8 p-8 border border-gray-300 rounded-lg bg-white shadow-md">
        <h2 class="mb-4 text-lg font-semibold">Pay Invoice</h2>

        <div class="w-full space-y-4">
            <!-- Payment method section -->
            <div class="payment-method">
                <!-- Card icons here -->
            </div>

            <!-- Payment amount section -->
            <div class="payment-amount">

                <label for="amount" class="block text-sm font-medium text-gray-700">Payment amount</label>
                <div class="mt-1 relative rounded-md shadow-sm">
                    <!-- We bind the value to paymentAmount and also display it in the placeholder -->
                    <input type="text" id="amount" :value="`$${paymentAmount}`"
                           class="form-input block w-full sm:text-sm border-gray-300 rounded-md p-2" readonly/>
                </div>
            </div>

            <!-- Name on card section -->
            <div class="input-group">
                <label for="cardName" class="block mb-2">Name on card</label>
                <input type="text" id="cardName" v-model="cardName"
                       class="form-input block w-full p-2 border border-gray-300 rounded-md" placeholder="Name on card">
            </div>

            <!-- Card number section -->
            <div class="input-group">
                <label for="cardNumber" class="block mb-2">Card number</label>
                <input type="text" id="cardNumber" v-model="cardNumber"
                       class="form-input block w-full p-2 border border-gray-300 rounded-md" placeholder="Card number"
                       maxlength="16">
            </div>

            <!-- Expiry date and security code section -->
            <div class="flex gap-4">
                <div class="input-group flex-1">
                    <label for="expiry" class="block mb-2">Expiry date</label>
                    <input type="text" id="expiry" v-model="expiry"
                           class="form-input block w-full p-2 border border-gray-300 rounded-md" placeholder="MM/YY">
                </div>
                <div class="input-group flex-1">
                    <label for="securityCode" class="block mb-2">Security code</label>
                    <input type="text" id="securityCode" v-model="securityCode"
                           class="form-input block w-full p-2 border border-gray-300 rounded-md" placeholder="CVV"
                           maxlength="3">
                </div>
            </div>

            <!-- ZIP/Postal code section -->
            <div class="input-group">
                <label for="zip" class="block mb-2">ZIP/Postal code</label>
                <input type="text" id="zip" v-model="postalCode"
                       class="form-input block w-full p-2 border border-gray-300 rounded-md" placeholder="ZIP Code">
            </div>

            <!-- PrimeVue Button for payment submission -->
            <Button label="Pay" @click="submitPayment" class="w-full mt-4"/>
        </div>
        <Toast/>
    </div>
</template>


