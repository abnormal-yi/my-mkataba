export default function Toast({ visible, message }) {
  if (!visible) return null
  return <div className="toast">{message}</div>
}
