<script setup>
import TypeLayout from './TypeLayout.vue'
import DateTime from './DateTime.vue'

defineProps({
  item: {
    required: true,
    type: Object
  }
})
</script>
<template>
  <TypeLayout>
    <template #default>
      <template v-if="item.date_times.old_scheduled_at && item.date_times.new_scheduled_at">
        <i18n-t keypath="post_activity.update_scheduled_at" tag="div" scope="global">
          <template #user>
            <span>{{ item.user.name }}</span>
          </template>
          <template #old_datetime>
            <DateTime>{{ item.date_times.old_scheduled_at.localized }}</DateTime>
          </template>
          <template #new_datetime>
            <DateTime>{{ item.date_times.new_scheduled_at.localized }}</DateTime>
          </template>
        </i18n-t>
      </template>
    </template>
    <template #created_at>
      {{ item.timestamps.localized.created_at }}
    </template>
  </TypeLayout>
</template>
