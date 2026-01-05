<?php

namespace Inovector\Mixpost\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;
use Illuminate\Support\Facades\Http;
use Inovector\Mixpost\Concerns\UsesFileConfig;
use Inovector\Mixpost\Enums\FileSizeUnit;
use Inovector\Mixpost\Support\File as FileSupport;

class RemoteFileRule implements ValidationRule
{
    use UsesFileConfig;

    protected int $timeout = 10;

    public function timeout(int $seconds): self
    {
        $this->timeout = $seconds;

        return $this;
    }

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value) || ! filter_var($value, FILTER_VALIDATE_URL)) {
            $fail(__('mixpost::rules.remote_file.invalid_url'));

            return;
        }

        try {
            $response = Http::timeout($this->timeout)->head($value);

            if (! $response->successful()) {
                $fail(__('mixpost::rules.remote_file.not_accessible'));

                return;
            }

            $contentType = $response->header('Content-Type');

            if (! $contentType) {
                $fail(__('mixpost::rules.remote_file.undetermined_file_type'));

                return;
            }

            $mimeType = $this->extractMimeType($contentType);

            if (! in_array($mimeType, $this->allowedMimeTypes(), true)) {
                $fail(__('mixpost::rules.remote_file.mime_type_not_allowed', ['type' => $mimeType]));

                return;
            }

            $contentLength = $response->header('Content-Length');

            if ($contentLength !== null) {
                $fileSizeBytes = (int) $contentLength;
                $maxSizeBytes = $this->maxSizeForMimeType($mimeType, FileSizeUnit::BYTES);

                if ($maxSizeBytes > 0 && $fileSizeBytes > $maxSizeBytes) {
                    $fileType = FileSupport::isImage($mimeType) ? 'image' : 'video';
                    $maxSizeMb = $this->maxSizeForMimeType($mimeType, FileSizeUnit::MB);

                    $fail(__('mixpost::rules.file_max_size', ['type' => $fileType, 'max' => $maxSizeMb]));
                }
            }
        } catch (\Exception) {
            $fail(__('mixpost::rules.remote_file.validation_failed'));
        }
    }

    protected function extractMimeType(string $contentType): string
    {
        $parts = explode(';', $contentType);

        return trim($parts[0]);
    }
}
