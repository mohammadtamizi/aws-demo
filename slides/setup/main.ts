// Import the global CSS file
import '../style.css'

// This setup file is automatically loaded by Slidev
export default {
  // Configure aspect ratio and scaling
  aspectRatio: 16/9,
  canvasWidth: 980,

  // Ensure content scales properly
  scales: {
    // Scale content in presenter mode
    presenter: 1,
    // Scale content in export
    export: 1,
    // Scale content in overview
    overview: 1
  }
}
