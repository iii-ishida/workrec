import React from 'react'
import PropTypes from 'prop-types'
import styles from './AddWork.module.css'

const AddWork = ({ addWork }) => {
  let input

  return (
    <div>
      <form className={styles.addWork} onSubmit={e => {
        e.preventDefault()
        if (!input.value.trim()) {
          return
        }
        addWork(input.value)
        input.value = ''
      }}>
        <input className={styles.titleText} placeholder='タイトル' ref={node => input = node} />
        <button className={styles.addButton} type='submit'>
          Add Work
        </button>
      </form>
    </div>
  )
}

AddWork.propTypes = {
  addWork: PropTypes.func.isRequired,
}

export default AddWork
