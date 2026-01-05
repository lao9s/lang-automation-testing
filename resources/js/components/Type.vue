<script setup>
import { computed } from 'vue'
import { SCHEDULED, NEEDS_APPROVAL } from '@/Constants/PostStatus'
import TypeLayout from './TypeLayout.vue'
import DateTime from './DateTime.vue'

const props = defineProps({
  item: {
    required: true,
    type: Object
  }
})

const keyPath = computed(() => {
  if (props.item.data.status === NEEDS_APPROVAL) {
    return 'post_activity.schedule_approval'
  } else if (props.item.data.status === SCHEDULED && props.item.data.with_approval) {
    return 'post_activity.post_approved'
  } else {
    return 'post_activity.scheduled_post'
  }
})
</script>
<template>
  <TypeLayout>
    <template #default>
      <i18n-t :keypath="keyPath" tag="div" scope="global">
        <template #user>
          <span>{{ item.user.name }}</span>
        </template>
        <template #datetime>
          <DateTime>{{ item.date_times.scheduled_at.localized }}</DateTime>
        </template>
      </i18n-t>
    </template>
    <template #created_at>
      {{ item.timestamps.localized.created_at }}
    </template>
  </TypeLayout>
</template>
