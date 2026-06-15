export default function Logo({ size = 36 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 80 80" fill="none">
      <rect width="80" height="80" rx="20" fill="#6C3FC5"/>
      <path d="M26 52V32l14-10 14 10v20H26z" fill="white" opacity=".9"/>
      <path d="M32 52V36l8-6 8 6v16H32z" fill="#6C3FC5"/>
      <path d="M21 28c0-4 4-8 8-8l11-4 11 4c4 0 8 4 8 8" stroke="white" strokeWidth="3" fill="none"/>
      <circle cx="40" cy="48" r="8" fill="white" opacity=".3"/>
      <circle cx="40" cy="48" r="4" fill="white"/>
    </svg>
  )
}
